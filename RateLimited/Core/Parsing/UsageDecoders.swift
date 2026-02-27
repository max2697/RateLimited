import Foundation

enum ClaudeUsageDecoder {
    static func decodeSnapshot(from data: Data) throws -> ToolUsageSnapshot {
        let response = try JSONDecoder().decode(ClaudeUsageResponse.self, from: data)
        return ToolUsageSnapshot(
            fiveHour: UsageWindow(
                usedPercent: response.fiveHour.utilization,
                resetDate: try ISO8601Parser.parseIfPresent(response.fiveHour.resetsAt)
            ),
            weekly: UsageWindow(
                usedPercent: response.sevenDay.utilization,
                resetDate: try ISO8601Parser.parseIfPresent(response.sevenDay.resetsAt)
            )
        )
    }
}

enum CodexUsageDecoder {
    static func decodeSnapshot(from data: Data, now: Date) throws -> ToolUsageSnapshot {
        let response = try JSONDecoder().decode(CodexUsageResponse.self, from: data)
        return ToolUsageSnapshot(
            fiveHour: UsageWindow(
                usedPercent: response.rateLimit.primaryWindow.usedPercent,
                resetDate: response.rateLimit.primaryWindow.resetAfterSeconds.map { now.addingTimeInterval($0) }
            ),
            weekly: UsageWindow(
                usedPercent: response.rateLimit.secondaryWindow.usedPercent,
                resetDate: response.rateLimit.secondaryWindow.resetAfterSeconds.map { now.addingTimeInterval($0) }
            )
        )
    }
}

private struct ClaudeUsageResponse: Decodable {
    let fiveHour: Window
    let sevenDay: Window

    struct Window: Decodable {
        let utilization: Double
        let resetsAt: String?

        enum CodingKeys: String, CodingKey {
            case utilization
            case resetsAt = "resets_at"
        }
    }

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
    }
}

private struct CodexUsageResponse: Decodable {
    let rateLimit: RateLimit

    struct RateLimit: Decodable {
        let primaryWindow: Window
        let secondaryWindow: Window

        enum CodingKeys: String, CodingKey {
            case primaryWindow = "primary_window"
            case secondaryWindow = "secondary_window"
        }
    }

    struct Window: Decodable {
        let usedPercent: Double
        let resetAfterSeconds: TimeInterval?

        enum CodingKeys: String, CodingKey {
            case usedPercent = "used_percent"
            case resetAfterSeconds = "reset_after_seconds"
        }
    }

    enum CodingKeys: String, CodingKey {
        case rateLimit = "rate_limit"
    }
}
