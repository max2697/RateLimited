import Foundation

struct NotInstalledUsageService: UsageSnapshotFetching, Sendable {
    let toolName: String

    func fetchUsage() async throws -> ToolUsageSnapshot {
        throw UsageServiceError("\(toolName) not found, install CLI first")
    }
}
