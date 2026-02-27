import Foundation

enum AppEnvironment {
    static func useMockData(_ env: [String: String] = ProcessInfo.processInfo.environment) -> Bool {
        env["RATELIMITED_USE_MOCK_DATA"] == "1"
    }
}

enum UsageViewModelFactory {
    static func makeDefault() -> UsageViewModel {
        if AppEnvironment.useMockData() {
            return UsageViewModel(
                claudeService: MockUsageService(snapshotProvider: { MockUsageProvider.claudeSnapshot() }),
                codexService: MockUsageService(snapshotProvider: { MockUsageProvider.codexSnapshot() })
            )
        }

        return UsageViewModel(
            claudeService: ClaudeUsageService(),
            codexService: CodexUsageService()
        )
    }
}
