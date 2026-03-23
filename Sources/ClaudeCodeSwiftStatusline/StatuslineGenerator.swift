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
        let contextUsage = sessionAnalyzer.formatContextPercent(
            contextWindowSize: session.contextWindow.contextWindowSize,
            currentUsage: session.contextWindow.currentUsage
        )
        let tokens = session.contextWindow.currentUsage?.totalContextTokens ?? 0
        let contextPct = Int((Double(tokens) / Double(session.contextWindow.contextWindowSize) * 100.0).rounded())

        let blue = "\u{001b}[34m"
        let magenta = "\u{001b}[35m"
        let reset = "\u{001b}[0m"

        var parts = [
            "\(reset)\(blue)\(pathWithBranch)\(reset)",
            "\(magenta)\(modelName)\(reset)",
            "\(ansiColor(forPercent: contextPct))\(contextUsage)\(reset)"
        ]

        if let fiveHour = session.rateLimits?.fiveHour {
            let pct = Int(fiveHour.usedPercentage.rounded())
            let countdown = timeManager.formatTimeUntil(fiveHour.resetsAt)
            parts.append("\(ansiColor(forPercent: pct))5h: \(pct)% (\(countdown))\(reset)")
        }

        if let sevenDay = session.rateLimits?.sevenDay {
            let pct = Int(sevenDay.usedPercentage.rounded())
            let countdown = timeManager.formatTimeUntil(sevenDay.resetsAt)
            parts.append("\(ansiColor(forPercent: pct))7d: \(pct)% (\(countdown))\(reset)")
        }

        return parts.joined(separator: " | ")
    }

    private func ansiColor(forPercent percent: Int) -> String {
        switch percent {
        case ..<70:  return "\u{001b}[32m"  // green
        case 70..<90: return "\u{001b}[33m"  // yellow
        default:      return "\u{001b}[31m"  // red
        }
    }

    private func readStdinData() -> Data? {
        let data = FileHandle.standardInput.readDataToEndOfFile()
        return data.isEmpty ? nil : data
    }

    private func parseSession(from data: Data) -> ClaudeCodeSession? {
        try? JSONDecoder().decode(ClaudeCodeSession.self, from: data)
    }
}
