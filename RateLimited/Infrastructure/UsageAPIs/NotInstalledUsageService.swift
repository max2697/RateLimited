import Foundation

struct NotInstalledUsageService: UsageSnapshotFetching {
    let toolName: String

    func fetchUsage() async throws -> ToolUsageSnapshot {
        throw UsageServiceError("\(toolName) not found, install CLI first")
    }
}
