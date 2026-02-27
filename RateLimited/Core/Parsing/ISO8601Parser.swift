import Foundation

enum ISO8601Parser {
    private nonisolated(unsafe) static let withFractionalSeconds: ISO8601DateFormatter = {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fmt
    }()

    private nonisolated(unsafe) static let withoutFractionalSeconds: ISO8601DateFormatter = {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime]
        return fmt
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
