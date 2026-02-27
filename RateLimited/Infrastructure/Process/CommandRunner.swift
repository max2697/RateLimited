import Darwin
import Foundation

struct CommandOutput: Sendable {
    let terminationStatus: Int32
    let stdoutData: Data
    let stderrData: Data
}

protocol CommandRunning: Sendable {
    nonisolated func run(executableURL: URL, arguments: [String], timeoutSeconds: TimeInterval?) throws -> CommandOutput
}

struct ProcessCommandRunner: CommandRunning {
    private let clock: any Clock

    init(clock: any Clock = SystemClock()) {
        self.clock = clock
    }

    nonisolated func run(
        executableURL: URL,
        arguments: [String],
        timeoutSeconds: TimeInterval? = nil
    ) throws -> CommandOutput {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        try process.run()

        // Drain pipes concurrently on background threads to prevent deadlock
        // when subprocess output exceeds the pipe buffer (~64 KB).
        let group = DispatchGroup()
        var stdoutData = Data()
        var stderrData = Data()

        let ioQueue = DispatchQueue(label: "net.0fn.RateLimited.CommandRunner.io", attributes: .concurrent)

        group.enter()
        ioQueue.async {
            stdoutData = stdout.fileHandleForReading.readDataToEndOfFile()
            group.leave()
        }

        group.enter()
        ioQueue.async {
            stderrData = stderr.fileHandleForReading.readDataToEndOfFile()
            group.leave()
        }

        if let timeoutSeconds {
            let deadline = clock.now().addingTimeInterval(timeoutSeconds)
            while process.isRunning && clock.now() < deadline {
                Thread.sleep(forTimeInterval: 0.05)
            }
            if process.isRunning {
                process.terminate()
                // Give SIGTERM a brief grace period, then force-kill so that
                // waitUntilExit() below is guaranteed to return promptly.
                let killDeadline = clock.now().addingTimeInterval(2)
                while process.isRunning && clock.now() < killDeadline {
                    Thread.sleep(forTimeInterval: 0.05)
                }
                if process.isRunning {
                    kill(process.processIdentifier, SIGKILL)
                }
            }
        }

        process.waitUntilExit()
        group.wait()

        return CommandOutput(
            terminationStatus: process.terminationStatus,
            stdoutData: stdoutData,
            stderrData: stderrData
        )
    }
}
