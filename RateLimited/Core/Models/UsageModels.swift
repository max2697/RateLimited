import Foundation

struct UsageWindow {
    let usedPercent: Double
    let resetDate: Date?

    nonisolated init(usedPercent: Double, resetDate: Date?) {
        self.usedPercent = max(0, min(usedPercent, 100))
        self.resetDate = resetDate
    }
}

struct ToolUsageSnapshot {
    let fiveHour: UsageWindow
    let weekly: UsageWindow
}

struct ToolUsageState {
    let snapshot: ToolUsageSnapshot?
    let errorMessage: String?

    static let idle = ToolUsageState(snapshot: nil, errorMessage: nil)
}
