import XCTest
@testable import RateLimitedCore

@MainActor
final class UsageViewModelTests: XCTestCase {
    func testRefreshKeepsLastSnapshotForFailedToolAndUpdatesTimestampWhenOtherSucceeds() async {
        let firstClaude = ToolUsageSnapshot(
            fiveHour: UsageWindow(usedPercent: 11, resetDate: Date(timeIntervalSince1970: 1_700_000_000)),
            weekly: UsageWindow(usedPercent: 31, resetDate: Date(timeIntervalSince1970: 1_700_010_000))
        )
        let firstCodex = ToolUsageSnapshot(
            fiveHour: UsageWindow(usedPercent: 19, resetDate: Date(timeIntervalSince1970: 1_700_020_000)),
            weekly: UsageWindow(usedPercent: 49, resetDate: Date(timeIntervalSince1970: 1_700_030_000))
        )
        let secondCodex = ToolUsageSnapshot(
            fiveHour: UsageWindow(usedPercent: 26, resetDate: Date(timeIntervalSince1970: 1_700_040_000)),
            weekly: UsageWindow(usedPercent: 55, resetDate: Date(timeIntervalSince1970: 1_700_050_000))
        )

        let claudeService = StubUsageService(results: [.success(firstClaude), .failure(TestError.failed)])
        let codexService = StubUsageService(results: [.success(firstCodex), .success(secondCodex)])
        let dateProvider = SequenceDateProvider(
            dates: [
                Date(timeIntervalSince1970: 1_800_000_000),
                Date(timeIntervalSince1970: 1_800_000_300)
            ]
        )

        let viewModel = UsageViewModel(
            claudeService: claudeService,
            codexService: codexService,
            dateProvider: dateProvider.next
        )

        await viewModel.refresh()
        let firstUpdatedAt = viewModel.lastUpdated
        assertSnapshot(viewModel.claudeState.snapshot, equals: firstClaude)
        XCTAssertNil(viewModel.claudeState.errorMessage)
        assertSnapshot(viewModel.codexState.snapshot, equals: firstCodex)

        await viewModel.refresh()

        assertSnapshot(viewModel.claudeState.snapshot, equals: firstClaude)
        XCTAssertEqual(viewModel.claudeState.errorMessage, TestError.failed.localizedDescription)
        assertSnapshot(viewModel.codexState.snapshot, equals: secondCodex)
        XCTAssertNil(viewModel.codexState.errorMessage)
        XCTAssertNotEqual(viewModel.lastUpdated, firstUpdatedAt)
        XCTAssertEqual(viewModel.lastUpdated, Date(timeIntervalSince1970: 1_800_000_300))
    }

    func testRefreshDoesNotUpdateTimestampWhenBothToolsFail() async {
        let firstSnapshot = ToolUsageSnapshot(
            fiveHour: UsageWindow(usedPercent: 8, resetDate: Date(timeIntervalSince1970: 1_700_000_000)),
            weekly: UsageWindow(usedPercent: 18, resetDate: Date(timeIntervalSince1970: 1_700_010_000))
        )

        let claudeService = StubUsageService(results: [.success(firstSnapshot), .failure(TestError.failed)])
        let codexService = StubUsageService(results: [.success(firstSnapshot), .failure(TestError.failed)])
        let dateProvider = SequenceDateProvider(
            dates: [
                Date(timeIntervalSince1970: 1_900_000_000),
                Date(timeIntervalSince1970: 1_900_000_100)
            ]
        )

        let viewModel = UsageViewModel(
            claudeService: claudeService,
            codexService: codexService,
            dateProvider: dateProvider.next
        )

        await viewModel.refresh()
        let successfulRefreshDate = viewModel.lastUpdated
        XCTAssertEqual(successfulRefreshDate, Date(timeIntervalSince1970: 1_900_000_000))

        await viewModel.refresh()
        XCTAssertEqual(viewModel.lastUpdated, successfulRefreshDate)
    }

    private func assertSnapshot(
        _ actual: ToolUsageSnapshot?,
        equals expected: ToolUsageSnapshot,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let actual else {
            XCTFail("Expected snapshot but got nil", file: file, line: line)
            return
        }

        XCTAssertEqual(actual.fiveHour.usedPercent, expected.fiveHour.usedPercent, file: file, line: line)
        XCTAssertEqual(actual.fiveHour.resetDate, expected.fiveHour.resetDate, file: file, line: line)
        XCTAssertEqual(actual.weekly.usedPercent, expected.weekly.usedPercent, file: file, line: line)
        XCTAssertEqual(actual.weekly.resetDate, expected.weekly.resetDate, file: file, line: line)
    }
}

private actor SnapshotSequence {
    private var results: [Result<ToolUsageSnapshot, Error>]

    init(results: [Result<ToolUsageSnapshot, Error>]) {
        self.results = results
    }

    func next() throws -> ToolUsageSnapshot {
        guard !results.isEmpty else {
            throw TestError.noMoreResults
        }
        return try results.removeFirst().get()
    }
}

private struct StubUsageService: UsageSnapshotFetching {
    private let sequence: SnapshotSequence

    init(results: [Result<ToolUsageSnapshot, Error>]) {
        sequence = SnapshotSequence(results: results)
    }

    func fetchUsage() async throws -> ToolUsageSnapshot {
        try await sequence.next()
    }
}

private final class SequenceDateProvider: @unchecked Sendable {
    private var dates: [Date]

    init(dates: [Date]) {
        self.dates = dates
    }

    func next() -> Date {
        guard !dates.isEmpty else {
            return Date.distantFuture
        }
        return dates.removeFirst()
    }
}

private enum TestError: LocalizedError {
    case failed
    case noMoreResults

    var errorDescription: String? {
        switch self {
        case .failed:
            return "failed"
        case .noMoreResults:
            return "no more results"
        }
    }
}
