import Foundation

protocol Clock: Sendable {
    nonisolated func now() -> Date
}

struct SystemClock: Clock {
    // swiftlint:disable:next unneeded_synthesized_initializer
    nonisolated init() {}

    nonisolated func now() -> Date {
        Date()
    }
}
