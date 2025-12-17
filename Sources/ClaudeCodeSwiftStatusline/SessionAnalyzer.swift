import Foundation

struct SessionAnalyzer {

    func formatContextPercent(contextWindowSize: Int, currentUsage: CurrentUsage?) -> String {
        let tokenCount = currentUsage?.totalContextTokens ?? 0
        let percent = Double(tokenCount) / Double(contextWindowSize) * 100.0
        let contextPercent = Int(percent.rounded())

        let formattedTokens = formatTokenCount(tokenCount)
        let formattedContextWindow = formatContextWindowSize(contextWindowSize)
        return "\(formattedTokens)/\(formattedContextWindow) (\(contextPercent)%)"
    }

    func getAllRecentSessions(billingWindowHours: Int, secondsPerHour: Int) -> [SessionData] {
        let projectDirs = getClaudeProjectDirectories()
        var allSessions: [SessionData] = []
        let cutoffTime = Date().addingTimeInterval(-TimeInterval(billingWindowHours * secondsPerHour))

        for projectDir in projectDirs {
            guard projectDir.hasDirectoryPath else { continue }

            do {
                let jsonlFiles = try FileManager.default.contentsOfDirectory(
                    at: projectDir,
                    includingPropertiesForKeys: [.contentModificationDateKey],
                    options: [.skipsHiddenFiles]
                ).filter { $0.pathExtension == "jsonl" }

                for jsonlFile in jsonlFiles {
                    if let modificationDate = try? jsonlFile.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                       modificationDate > cutoffTime,
                       let sessionData = analyzeSessionFile(jsonlFile) {
                        allSessions.append(sessionData)
                    }
                }
            } catch {
                continue
            }
        }

        return allSessions.sorted { $0.startTime < $1.startTime }
    }

    func analyzeSessionFile(_ url: URL) -> SessionData? {
        var timestamps: [Date] = []

        parseJsonlFile(url) { json in
            guard let timestampString = json["timestamp"] as? String,
                  let timestamp = parseTimestamp(timestampString) else {
                return
            }
            timestamps.append(timestamp)
        }

        guard !timestamps.isEmpty else { return nil }

        let sessionId = url.deletingPathExtension().lastPathComponent
        let startTime = floorToHour(timestamps.sorted().first!)

        return SessionData(id: sessionId, startTime: startTime)
    }

    func getFirstTimestamp(from sessionFile: URL) -> Date? {
        var firstTimestamp: Date?

        parseJsonlFile(sessionFile) { json in
            guard firstTimestamp == nil,
                  let timestampString = json["timestamp"] as? String,
                  let timestamp = parseTimestamp(timestampString) else {
                return
            }
            firstTimestamp = timestamp
        }

        return firstTimestamp
    }

    private func formatTokenCount(_ tokens: Int) -> String {
        // Format token counts: show as "k" notation for values >= 1000
        if tokens >= 1000 {
            let k = Double(tokens) / 1000.0
            return String(format: "%.1fk", k)
        } else {
            return "\(tokens)"
        }
    }

    private func formatContextWindowSize(_ size: Int) -> String {
        // Format context window: 1M for million, 200k for thousands
        if size >= 1_000_000 {
            let m = Double(size) / 1_000_000.0
            return m == 1.0 ? "1M" : String(format: "%.1fM", m)
        } else if size >= 1000 {
            let k = Double(size) / 1000.0
            return k.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(k))k" : String(format: "%.1fk", k)
        } else {
            return "\(size)"
        }
    }

    private func getClaudeProjectDirectories() -> [URL] {
        let projectsPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/projects")

        guard let projectDirs = try? FileManager.default.contentsOfDirectory(
            at: projectsPath,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return projectDirs
    }

    private func parseJsonlFile(_ url: URL, handler: ([String: Any]) -> Void) {
        guard let data = try? Data(contentsOf: url),
              let content = String(data: data, encoding: .utf8) else {
            return
        }

        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

        for line in lines {
            guard let lineData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: lineData) as? [String: Any] else {
                continue
            }
            handler(json)
        }
    }

    private func parseTimestamp(_ timestamp: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")

        if let date = formatter.date(from: timestamp) {
            return date
        }

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.date(from: timestamp)
    }

    private func floorToHour(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return calendar.date(from: components) ?? date
    }
}