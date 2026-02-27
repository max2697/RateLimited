import Foundation

protocol AccessTokenProviding: Sendable {
    nonisolated func readAccessToken() async throws -> String
}

struct CLIAuthRefresher: Sendable {
    private let command: [String]
    private let commandRunner: any CommandRunning

    init(command: [String], commandRunner: any CommandRunning = ProcessCommandRunner()) {
        self.command = command
        self.commandRunner = commandRunner
    }

    nonisolated func refreshBestEffort(timeoutSeconds: TimeInterval = 30) {
        guard let name = command.first,
              let executableURL = CLIAuthRefresher.resolveExecutable(name) else { return }
        _ = try? commandRunner.run(
            executableURL: executableURL,
            arguments: Array(command.dropFirst()),
            timeoutSeconds: timeoutSeconds
        )
    }

    private nonisolated static func resolveExecutable(_ name: String) -> URL? {
        let home = URL(fileURLWithPath: NSHomeDirectory())
        let candidates = [
            home.appendingPathComponent(".local/bin/\(name)"),
            home.appendingPathComponent(".claude/local/\(name)"),
            URL(fileURLWithPath: "/opt/homebrew/bin/\(name)"),
            URL(fileURLWithPath: "/usr/local/bin/\(name)"),
            URL(fileURLWithPath: "/usr/bin/\(name)"),
        ]
        return candidates.first { access($0.path, X_OK) == 0 }
    }
}

struct ClaudeTokenProvider: AccessTokenProviding, Sendable {
    private let commandRunner: any CommandRunning

    init(commandRunner: any CommandRunning = ProcessCommandRunner()) {
        self.commandRunner = commandRunner
    }

    nonisolated func readAccessToken() async throws -> String {
        let commandRunner = self.commandRunner

        return try await Task.detached(priority: .userInitiated) {
            let output = try commandRunner.run(
                executableURL: URL(fileURLWithPath: "/usr/bin/security"),
                arguments: ["find-generic-password", "-s", "Claude Code-credentials", "-w"],
                timeoutSeconds: nil
            )

            guard output.terminationStatus == 0 else {
                let stderrText = String(data: output.stderrData, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                throw UsageServiceError(
                    "Claude token lookup failed: \(stderrText ?? "security exited \(output.terminationStatus)")"
                )
            }

            let rawSecret = String(data: output.stdoutData, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !rawSecret.isEmpty else {
                throw UsageServiceError("Claude token lookup returned an empty secret")
            }

            return try ClaudeTokenExtractor.extractAccessToken(fromKeychainSecretData: Data(rawSecret.utf8))
        }.value
    }
}

struct CodexTokenProvider: AccessTokenProviding, Sendable {
    private let authFileURL: URL

    init(
        authFileURL: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".codex")
            .appendingPathComponent("auth.json")
    ) {
        self.authFileURL = authFileURL
    }

    nonisolated func readAccessToken() async throws -> String {
        let authFileURL = self.authFileURL

        return try await Task.detached(priority: .userInitiated) {
            let data = try Data(contentsOf: authFileURL)
            return try CodexTokenExtractor.extractAccessToken(fromAuthJSONData: data)
        }.value
    }
}
