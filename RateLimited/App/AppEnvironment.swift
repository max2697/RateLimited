import Foundation

extension Bundle {
    var appVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

enum AppEnvironment {
    static func useMockData(_ env: [String: String] = ProcessInfo.processInfo.environment) -> Bool {
        env["RATELIMITED_USE_MOCK_DATA"] == "1"
    }
}

enum UsageViewModelFactory {
    @MainActor
    static func makeDefault() -> UsageViewModel {
        if AppEnvironment.useMockData() {
            return UsageViewModel(
                claudeService: MockUsageService(snapshotProvider: { MockUsageProvider.claudeSnapshot() }),
                codexService: MockUsageService(snapshotProvider: { MockUsageProvider.codexSnapshot() })
            )
        }

        let claudeService: any UsageSnapshotFetching = CLIAuthRefresher.isInstalled("claude")
            ? ClaudeUsageService()
            : NotInstalledUsageService(toolName: "claude")

        let codexService: any UsageSnapshotFetching = CLIAuthRefresher.isInstalled("codex")
            ? CodexUsageService()
            : NotInstalledUsageService(toolName: "codex")

        return UsageViewModel(claudeService: claudeService, codexService: codexService)
    }
}
