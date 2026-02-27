import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarAppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private let viewModel: UsageViewModel
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        self.viewModel = UsageViewModelFactory.makeDefault()
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        configurePopover()
        configureStatusItem()
        configureViewModel()
        scheduleRefreshTimer()

        Task {
            await refreshUsage()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        refreshTimer?.invalidate()
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 360, height: 320)
        popover.contentViewController = NSHostingController(rootView: UsagePopoverView(viewModel: viewModel))
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        button.title = viewModel.menuBarTitle
        button.action = #selector(togglePopover(_:))
        button.target = self
        button.toolTip = "RateLimited"
    }

    private func configureViewModel() {
        viewModel.$menuBarTitle
            .sink { [weak self] title in
                self?.statusItem.button?.title = title
            }
            .store(in: &cancellables)
    }

    private func scheduleRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.refreshUsage()
            }
        }
    }

    private func refreshUsage() async {
        await viewModel.refresh()
    }

    @objc
    private func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
