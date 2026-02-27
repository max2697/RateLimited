import Foundation

enum ISO8601Parser {
    nonisolated(unsafe) private static let withFractionalSeconds: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    nonisolated(unsafe) private static let withoutFractionalSeconds: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    nonisolated static func parse(_ string: String) throws -> Date {
        if let date = withFractionalSeconds.date(from: string) ?? withoutFractionalSeconds.date(from: string) {
            return date
        }
        throw UsageServiceError("Unable to parse reset time: \(string)")
    }

    nonisolated static func parseIfPresent(_ string: String?) throws -> Date? {
        guard let string else { return nil }
        return try parse(string)
    }
}
