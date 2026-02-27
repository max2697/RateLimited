import SwiftUI

@main
struct RateLimitedApp: App {
    @NSApplicationDelegateAdaptor(StatusBarAppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
                .frame(width: 1, height: 1)
        }
    }
}
