import Foundation

enum ClaudeAuthErrorClassifier {
    nonisolated static func isTokenExpiredResponseBody(_ data: Data?) -> Bool {
        guard
            let data,
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let type = object["type"] as? String,
            type == "error",
            let error = object["error"] as? [String: Any],
            let errorType = error["type"] as? String,
            errorType == "authentication_error"
        else {
            return false
        }

        if let errorCode = error["error_code"] as? String {
            return errorCode == "token_expired"
        }

        if let message = error["message"] as? String {
            return message.localizedCaseInsensitiveContains("token has expired")
        }

        return false
    }
}
