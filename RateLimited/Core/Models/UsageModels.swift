import Foundation

struct UsageWindow: Sendable {
    let usedPercent: Double
    let resetDate: Date?

    nonisolated init(usedPercent: Double, resetDate: Date?) {
        self.usedPercent = max(0, min(usedPercent, 100))
        self.resetDate = resetDate
    }
}

struct ToolUsageSnapshot: Sendable {
    let fiveHour: UsageWindow
    let weekly: UsageWindow
}

struct ToolUsageState: Sendable {
    let snapshot: ToolUsageSnapshot?
    let errorMessage: String?

    static let idle = ToolUsageState(snapshot: nil, errorMessage: nil)
}
