import Foundation

struct ClaudeUsageService: UsageSnapshotFetching {
    private let tokenProvider: any AccessTokenProviding
    private let authRefresher: CLIAuthRefresher
    private let httpClient: any HTTPClient

    init(
        tokenProvider: any AccessTokenProviding = ClaudeTokenProvider(),
        authRefresher: CLIAuthRefresher = CLIAuthRefresher(command: ["claude", "-p", "hi"]),
        httpClient: any HTTPClient = URLSessionHTTPClient()
    ) {
        self.tokenProvider = tokenProvider
        self.authRefresher = authRefresher
        self.httpClient = httpClient
    }

    func fetchUsage() async throws -> ToolUsageSnapshot {
        let tokenProvider = tokenProvider
        let authRefresher = authRefresher

        // Proactively refresh if the token is already expired so we skip an unnecessary API round-trip.
        if let expiry = await tokenProvider.readTokenExpiry(), expiry <= Date() {
            await Task.detached(priority: .utility) {
                authRefresher.refreshBestEffort()
            }.value
        }

        return try await UsageServiceSupport.fetchWithSingleAuthRetry(
            readAccessToken: {
                try await tokenProvider.readAccessToken()
            },
            refreshAuth: {
                await Task.detached(priority: .utility) {
                    authRefresher.refreshBestEffort()
                }.value
            },
            shouldRetryAfterUnauthorized: { $0.statusCode == 401 },
            performRequest: { token in
                try await fetchUsage(usingToken: token)
            }
        )
    }

    // swiftlint:disable:next force_unwrapping
    private static let usageURL = URL(string: "https://api.anthropic.com/api/oauth/usage")!

    private func fetchUsage(usingToken token: String) async throws -> ToolUsageSnapshot {
        var request = URLRequest(url: Self.usageURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.setValue("claude-code/2.0.32", forHTTPHeaderField: "User-Agent")

        let data = try await httpClient.data(for: request)
        return try ClaudeUsageDecoder.decodeSnapshot(from: data)
    }
}
