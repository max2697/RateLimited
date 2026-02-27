import Combine
import Foundation

protocol UsageSnapshotFetching: Sendable {
    func fetchUsage() async throws -> ToolUsageSnapshot
}

@MainActor
final class UsageViewModel: ObservableObject {
    @Published private(set) var claudeState: ToolUsageState = .idle
    @Published private(set) var codexState: ToolUsageState = .idle
    @Published private(set) var menuBarTitle: String = "--"
    @Published private(set) var isRefreshing = false
    @Published private(set) var lastUpdated: Date?

    private let claudeService: any UsageSnapshotFetching
    private let codexService: any UsageSnapshotFetching
    private let dateProvider: () -> Date

    init(
        claudeService: any UsageSnapshotFetching,
        codexService: any UsageSnapshotFetching,
        dateProvider: @escaping () -> Date = { Date() }
    ) {
        self.claudeService = claudeService
        self.codexService = codexService
        self.dateProvider = dateProvider
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        let claudeService = self.claudeService
        let codexService = self.codexService

        async let claudeResult = Self.load {
            try await claudeService.fetchUsage()
        }
        async let codexResult = Self.load {
            try await codexService.fetchUsage()
        }

        let (newClaude, newCodex) = await (claudeResult, codexResult)
        claudeState = Self.merge(previous: claudeState, result: newClaude)
        codexState = Self.merge(previous: codexState, result: newCodex)
        menuBarTitle = UsageDisplayFormatter.menuBarTitle(codexState: codexState, claudeState: claudeState)

        if newClaude.isSuccess || newCodex.isSuccess {
            lastUpdated = dateProvider()
        }
    }

    private static func load(
        _ operation: @escaping @Sendable () async throws -> ToolUsageSnapshot
    ) async -> LoadResult {
        do {
            return .success(try await operation())
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return .failure(message)
        }
    }

    private static func merge(previous: ToolUsageState, result: LoadResult) -> ToolUsageState {
        switch result {
        case .success(let snapshot):
            return ToolUsageState(snapshot: snapshot, errorMessage: nil)
        case .failure(let errorMessage):
            // Preserve last known snapshot while surfacing the latest error.
            return ToolUsageState(snapshot: previous.snapshot, errorMessage: errorMessage)
        }
    }

    private enum LoadResult {
        case success(ToolUsageSnapshot)
        case failure(String)

        var isSuccess: Bool {
            switch self {
            case .success:
                true
            case .failure:
                false
            }
        }
    }
}

#if DEBUG
extension UsageViewModel {
    static func previewMock() -> UsageViewModel {
        let now = Date()
        let viewModel = UsageViewModel(
            claudeService: MockUsageService(snapshotProvider: { MockUsageProvider.claudeSnapshot(now: now) }),
            codexService: MockUsageService(snapshotProvider: { MockUsageProvider.codexSnapshot(now: now) })
        )

        viewModel.claudeState = ToolUsageState(snapshot: MockUsageProvider.claudeSnapshot(now: now), errorMessage: nil)
        viewModel.codexState = ToolUsageState(snapshot: MockUsageProvider.codexSnapshot(now: now), errorMessage: nil)
        viewModel.lastUpdated = now
        return viewModel
    }

    static func previewError() -> UsageViewModel {
        let now = Date()
        let viewModel = UsageViewModel(
            claudeService: MockUsageService(snapshotProvider: { MockUsageProvider.claudeSnapshot(now: now) }),
            codexService: MockUsageService(snapshotProvider: { MockUsageProvider.codexSnapshot(now: now) })
        )

        viewModel.codexState = ToolUsageState(
            snapshot: nil,
            errorMessage: "Codex token missing from ~/.codex/auth.json"
        )
        viewModel.claudeState = ToolUsageState(
            snapshot: MockUsageProvider.claudeSnapshot(now: now),
            errorMessage: "HTTP 401: Unauthorized"
        )
        viewModel.lastUpdated = now
        return viewModel
    }
}
#endif
