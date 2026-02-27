import Foundation

enum UsageDisplayFormatter {
    static func menuBarTitle(codexState: ToolUsageState, claudeState: ToolUsageState) -> String {
        "\(trayLabel(for: codexState)) \(trayLabel(for: claudeState))"
    }

    static func trayLabel(for state: ToolUsageState) -> String {
        trayLabel(for: state.snapshot)
    }

    static func trayLabel(for snapshot: ToolUsageSnapshot?) -> String {
        guard let snapshot else { return "--" }

        let weeklyRemainingPercent = max(0, 100 - snapshot.weekly.usedPercent)
        let showWeekly = weeklyRemainingPercent < 10
        let displayedPercent = showWeekly ? snapshot.weekly.usedPercent : snapshot.fiveHour.usedPercent
        let weeklyPrefix = showWeekly ? "w" : ""
        return "\(weeklyPrefix)\(Int(displayedPercent.rounded()))%"
    }

    static func timeRemainingString(until resetDate: Date, now: Date = Date()) -> String {
        let seconds = Int(resetDate.timeIntervalSince(now).rounded(.down))
        if seconds <= 0 { return "now" }

        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60

        if days > 0 {
            return hours > 0 ? "\(days)d \(hours)h" : "\(days)d"
        }
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }

        let clampedMinutes = max(minutes, 1)
        return clampedMinutes == 1 ? "1m" : "\(clampedMinutes)m"
    }
}
