import Foundation

enum ClaudeTokenExtractor {
    nonisolated static func extractAccessToken(fromKeychainSecretData data: Data) throws -> String {
        guard
            let object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let oauth = object["claudeAiOauth"] as? [String: Any],
            let token = oauth["accessToken"] as? String,
            !token.isEmpty
        else {
            throw UsageServiceError("Claude access token is missing in keychain JSON")
        }
        return token
    }
}

enum CodexTokenExtractor {
    nonisolated static func extractAccessToken(fromAuthJSONData data: Data) throws -> String {
        guard
            let object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let tokens = object["tokens"] as? [String: Any],
            let accessToken = tokens["access_token"] as? String,
            !accessToken.isEmpty
        else {
            throw UsageServiceError("Codex access token missing from ~/.codex/auth.json")
        }
        return accessToken
    }
}
