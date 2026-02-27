import Foundation

protocol Clock: Sendable {
    nonisolated func now() -> Date
}

struct SystemClock: Clock {
    nonisolated func now() -> Date {
        Date()
    }
}
