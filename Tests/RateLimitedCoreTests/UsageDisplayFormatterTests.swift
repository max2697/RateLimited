import XCTest
@testable import RateLimitedCore

final class UsageDisplayFormatterTests: XCTestCase {
    func testTrayLabelUsesHourlyByDefault() {
        let snapshot = ToolUsageSnapshot(
            fiveHour: UsageWindow(usedPercent: 96, resetDate: Date()),
            weekly: UsageWindow(usedPercent: 24, resetDate: Date())
        )

        XCTAssertEqual(UsageDisplayFormatter.trayLabel(for: snapshot), "96%")
    }

    func testTrayLabelUsesWeeklyWhenRemainingUnderTenPercent() {
        let snapshot = ToolUsageSnapshot(
            fiveHour: UsageWindow(usedPercent: 12, resetDate: Date()),
            weekly: UsageWindow(usedPercent: 93.6, resetDate: Date()) // 6.4% remaining
        )

        XCTAssertEqual(UsageDisplayFormatter.trayLabel(for: snapshot), "w94%")
    }

    func testMenuBarTitleOrdersCodexThenClaude() {
        let codex = ToolUsageState(
            snapshot: ToolUsageSnapshot(
                fiveHour: UsageWindow(usedPercent: 7, resetDate: Date()),
                weekly: UsageWindow(usedPercent: 50, resetDate: Date())
            ),
            errorMessage: nil
        )
        let claude = ToolUsageState(
            snapshot: ToolUsageSnapshot(
                fiveHour: UsageWindow(usedPercent: 96, resetDate: Date()),
                weekly: UsageWindow(usedPercent: 24, resetDate: Date())
            ),
            errorMessage: nil
        )

        XCTAssertEqual(UsageDisplayFormatter.menuBarTitle(codexState: codex, claudeState: claude), "7% 96%")
    }

    func testTimeRemainingStringFormatsMinutesHoursAndDays() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertEqual(
            UsageDisplayFormatter.timeRemainingString(until: now.addingTimeInterval(59), now: now),
            "1m"
        )
        XCTAssertEqual(
            UsageDisplayFormatter.timeRemainingString(until: now.addingTimeInterval(3 * 3600 + 55 * 60), now: now),
            "3h 55m"
        )
        XCTAssertEqual(
            UsageDisplayFormatter.timeRemainingString(until: now.addingTimeInterval(4 * 86_400 + 5 * 3600), now: now),
            "4d 5h"
        )
    }
}

