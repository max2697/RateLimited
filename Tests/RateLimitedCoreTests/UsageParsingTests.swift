import XCTest
@testable import RateLimitedCore

final class UsageParsingTests: XCTestCase {
    func testClaudeTokenExtractor() throws {
        let data = Data(#"{"claudeAiOauth":{"accessToken":"abc123"}}"#.utf8)
        XCTAssertEqual(try ClaudeTokenExtractor.extractAccessToken(fromKeychainSecretData: data), "abc123")
    }

    func testCodexTokenExtractor() throws {
        let data = Data(#"{"tokens":{"access_token":"xyz789"}}"#.utf8)
        XCTAssertEqual(try CodexTokenExtractor.extractAccessToken(fromAuthJSONData: data), "xyz789")
    }

    func testClaudeUsageDecoder() throws {
        let data = Data(
            #"""
            {
              "five_hour": { "utilization": 96, "resets_at": "2026-02-26T20:30:00Z" },
              "seven_day": { "utilization": 24, "resets_at": "2026-03-03T19:00:00Z" }
            }
            """#.utf8
        )

        let snapshot = try ClaudeUsageDecoder.decodeSnapshot(from: data)

        XCTAssertEqual(snapshot.fiveHour.usedPercent, 96)
        XCTAssertEqual(snapshot.weekly.usedPercent, 24)
    }

    func testClaudeUsageDecoderAllowsNullResetTime() throws {
        let data = Data(
            #"""
            {
              "five_hour": { "utilization": 0, "resets_at": null },
              "seven_day": { "utilization": 24, "resets_at": "2026-03-03T22:00:00.321406+00:00" }
            }
            """#.utf8
        )

        let snapshot = try ClaudeUsageDecoder.decodeSnapshot(from: data)

        XCTAssertEqual(snapshot.fiveHour.usedPercent, 0)
        XCTAssertNil(snapshot.fiveHour.resetDate)
        XCTAssertEqual(snapshot.weekly.usedPercent, 24)
        XCTAssertNotNil(snapshot.weekly.resetDate)
    }

    func testCodexUsageDecoder() throws {
        let data = Data(
            #"""
            {
              "rate_limit": {
                "primary_window": { "used_percent": 9, "reset_after_seconds": 14400 },
                "secondary_window": { "used_percent": 48, "reset_after_seconds": 360000 }
              }
            }
            """#.utf8
        )
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        let snapshot = try CodexUsageDecoder.decodeSnapshot(from: data, now: now)

        XCTAssertEqual(snapshot.fiveHour.usedPercent, 9)
        XCTAssertEqual(snapshot.weekly.usedPercent, 48)
        XCTAssertEqual(snapshot.fiveHour.resetDate, now.addingTimeInterval(14_400))
    }

    func testCodexUsageDecoderAllowsNullResetTime() throws {
        let data = Data(
            #"""
            {
              "rate_limit": {
                "primary_window": { "used_percent": 9, "reset_after_seconds": null },
                "secondary_window": { "used_percent": 48, "reset_after_seconds": 360000 }
              }
            }
            """#.utf8
        )
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        let snapshot = try CodexUsageDecoder.decodeSnapshot(from: data, now: now)

        XCTAssertEqual(snapshot.fiveHour.usedPercent, 9)
        XCTAssertNil(snapshot.fiveHour.resetDate)
        XCTAssertEqual(snapshot.weekly.resetDate, now.addingTimeInterval(360_000))
    }

    func testUsageWindowClampsPercent() {
        let window = UsageWindow(usedPercent: 125, resetDate: Date())
        XCTAssertEqual(window.usedPercent, 100)
    }

    func testClaudeAuthErrorClassifierDetectsTokenExpiredErrorCode() {
        let data = Data(
            #"""
            {
              "type": "error",
              "error": {
                "type": "authentication_error",
                "message": "OAuth token has expired.",
                "error_code": "token_expired"
              }
            }
            """#.utf8
        )

        XCTAssertTrue(ClaudeAuthErrorClassifier.isTokenExpiredResponseBody(data))
    }

    func testClaudeAuthErrorClassifierIgnoresOtherAuthErrors() {
        let data = Data(
            #"""
            {
              "type": "error",
              "error": {
                "type": "authentication_error",
                "message": "OAuth token invalid.",
                "error_code": "invalid_token"
              }
            }
            """#.utf8
        )

        XCTAssertFalse(ClaudeAuthErrorClassifier.isTokenExpiredResponseBody(data))
    }

    func testClaudeAuthErrorClassifierIgnoresNonErrorPayload() {
        let data = Data(#"{"ok":true}"#.utf8)
        XCTAssertFalse(ClaudeAuthErrorClassifier.isTokenExpiredResponseBody(data))
    }
}
