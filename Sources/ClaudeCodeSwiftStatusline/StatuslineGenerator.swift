import Foundation

struct StatuslineGenerator {

    private let gitManager = GitManager()
    private let modelManager = ModelManager()
    private let sessionAnalyzer = SessionAnalyzer()
    private let timeManager = TimeManager()

    func generateStatusline() -> String {
        guard let jsonData = readStdinData(),
              let session = parseSession(from: jsonData) else {
            return "Claude Code"
        }

        let pathWithBranch = gitManager.formatPathWithBranch(session.cwd)
        let modelName = modelManager.formatModelName(session.model)
        let contextPercent = sessionAnalyzer.formatContextPercent(contextWindowSize: session.contextWindow.contextWindowSize, currentUsage: session.contextWindow.currentUsage)
        let sessionDuration = timeManager.formatSessionDuration(session.cost?.totalDurationMs)
        let timeRemaining = timeManager.calculateTimeRemaining(sessionId: session.sessionId)
        let sessionId = session.sessionId

        // ANSI color codes: Blue → Purple → Green → Yellow (non-bold)
        let blue = "\u{001b}[34m"      // Path (blue)
        let purple = "\u{001b}[35m"    // Time remaining (magenta)
        let green = "\u{001b}[32m"     // Model (green)
        let yellow = "\u{001b}[33m"    // Session (yellow)
        let reset = "\u{001b}[0m"

        return "\(reset)\(blue)\(pathWithBranch)\(reset) | \(purple)\(timeRemaining)\(reset) | \(green)⛁ \(modelName) • \(contextPercent)\(reset) | \(yellow)⚡\(sessionDuration) • \(sessionId)\(reset)"
    }

    private func readStdinData() -> Data? {
        let stdin = FileHandle.standardInput
        let data = stdin.readDataToEndOfFile()
        return data.isEmpty ? nil : data
    }

    private func parseSession(from data: Data) -> ClaudeCodeSession? {
        do {
            return try JSONDecoder().decode(ClaudeCodeSession.self, from: data)
        } catch {
            return nil
        }
    }
}