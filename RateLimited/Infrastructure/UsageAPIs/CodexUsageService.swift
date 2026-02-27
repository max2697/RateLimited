import Foundation

struct CodexUsageService: UsageSnapshotFetching, Sendable {
    private let tokenProvider: any AccessTokenProviding
    private let authRefresher: CLIAuthRefresher
    private let httpClient: any HTTPClient
    private let clock: any Clock

    init(
        tokenProvider: any AccessTokenProviding = CodexTokenProvider(),
        authRefresher: CLIAuthRefresher = CLIAuthRefresher(command: ["codex", "login", "status"]),
        httpClient: any HTTPClient = URLSessionHTTPClient(),
        clock: any Clock = SystemClock()
    ) {
        self.tokenProvider = tokenProvider
        self.authRefresher = authRefresher
        self.httpClient = httpClient
        self.clock = clock
    }

    func fetchUsage() async throws -> ToolUsageSnapshot {
        let tokenProvider = tokenProvider
        let authRefresher = authRefresher

        return try await UsageServiceSupport.fetchWithSingleAuthRetry(
            readAccessToken: {
                try await tokenProvider.readAccessToken()
            },
            refreshAuth: {
                await Task.detached(priority: .utility) {
                    authRefresher.refreshBestEffort()
                }.value
            },
            shouldRetryAfterUnauthorized: {
                $0.statusCode == 401
            },
            performRequest: { token in
                try await fetchUsage(usingToken: token)
            }
        )
    }

    private func fetchUsage(usingToken token: String) async throws -> ToolUsageSnapshot {
        var request = URLRequest(url: URL(string: "https://chatgpt.com/backend-api/wham/usage")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let data = try await httpClient.data(for: request)
        return try CodexUsageDecoder.decodeSnapshot(from: data, now: clock.now())
    }
}
