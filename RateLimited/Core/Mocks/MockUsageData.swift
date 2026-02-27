import Foundation

enum MockUsageProvider {
    nonisolated static func codexSnapshot(now: Date = Date()) -> ToolUsageSnapshot {
        ToolUsageSnapshot(
            fiveHour: UsageWindow(usedPercent: 9, resetDate: now.addingTimeInterval(3 * 3600 + 55 * 60)),
            weekly: UsageWindow(usedPercent: 48, resetDate: now.addingTimeInterval(4 * 86400 + 5 * 3600))
        )
    }

    nonisolated static func claudeSnapshot(now: Date = Date()) -> ToolUsageSnapshot {
        ToolUsageSnapshot(
            fiveHour: UsageWindow(usedPercent: 96, resetDate: now.addingTimeInterval(12 * 60)),
            weekly: UsageWindow(usedPercent: 24, resetDate: now.addingTimeInterval(5 * 86400 + 3600))
        )
    }
}

struct MockUsageService: UsageSnapshotFetching {
    let snapshotProvider: @Sendable () -> ToolUsageSnapshot

    func fetchUsage() async throws -> ToolUsageSnapshot {
        snapshotProvider()
    }
}
