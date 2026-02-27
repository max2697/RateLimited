import Foundation

enum UsageServiceSupport {
    static func fetchWithSingleAuthRetry(
        readAccessToken: @escaping @Sendable () async throws -> String,
        refreshAuth: @escaping @Sendable () async -> Void,
        shouldRetryAfterUnauthorized: @escaping @Sendable (HTTPClientStatusError) -> Bool,
        performRequest: @escaping @Sendable (String) async throws -> ToolUsageSnapshot
    ) async throws -> ToolUsageSnapshot {
        let token = try await readAccessToken()

        do {
            return try await performRequest(token)
        } catch let error as HTTPClientStatusError where shouldRetryAfterUnauthorized(error) {
            await refreshAuth()
            let refreshedToken = try await readAccessToken()
            return try await performRequest(refreshedToken)
        }
    }
}
