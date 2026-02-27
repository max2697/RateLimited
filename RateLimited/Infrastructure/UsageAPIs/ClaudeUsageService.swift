import Foundation

struct ClaudeUsageService: UsageSnapshotFetching, Sendable {
    private let tokenProvider: any AccessTokenProviding
    private let authRefresher: CLIAuthRefresher
    private let httpClient: any HTTPClient

    init(
        tokenProvider: any AccessTokenProviding = ClaudeTokenProvider(),
        authRefresher: CLIAuthRefresher = CLIAuthRefresher(command: ["claude", "auth", "status"]),
        httpClient: any HTTPClient = URLSessionHTTPClient()
    ) {
        self.tokenProvider = tokenProvider
        self.authRefresher = authRefresher
        self.httpClient = httpClient
    }

    func fetchUsage() async throws -> ToolUsageSnapshot {
        let tokenProvider = self.tokenProvider
        let authRefresher = self.authRefresher

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
                $0.statusCode == 401 &&
                ClaudeAuthErrorClassifier.isTokenExpiredResponseBody($0.responseBodyData)
            },
            performRequest: { token in
                try await fetchUsage(usingToken: token)
            }
        )
    }

    private func fetchUsage(usingToken token: String) async throws -> ToolUsageSnapshot {
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/api/oauth/usage")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.setValue("claude-code/2.0.32", forHTTPHeaderField: "User-Agent")

        let data = try await httpClient.data(for: request)
        return try ClaudeUsageDecoder.decodeSnapshot(from: data)
    }
}
