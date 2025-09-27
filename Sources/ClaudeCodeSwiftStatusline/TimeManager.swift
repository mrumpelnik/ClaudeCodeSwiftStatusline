import Foundation

struct TimeManager {

    // Time conversion constants
    private let millisecondsPerMinute = 1000 * 60
    private let minutesPerHour = 60
    private let secondsPerHour = 3600
    private let secondsPerMinute = 60
    private let billingWindowHours = 5 // Claude Code billing window duration

    private let sessionAnalyzer = SessionAnalyzer()

    func formatSessionDuration(_ totalDurationMs: Int?) -> String {
        guard let durationMs = totalDurationMs else {
            return "0m"
        }

        // Convert duration from milliseconds to minutes, ensuring non-negative
        let minutes = max(0, durationMs / millisecondsPerMinute)
        return formatTimeComponents(hours: minutes / minutesPerHour, minutes: minutes % minutesPerHour)
    }

    func calculateTimeRemaining(sessionId: String) -> String {
        guard let activeWindow = findActiveBillingWindow() else {
            return "⏱ 5h 0m"
        }

        let timeRemaining = activeWindow.endTime.timeIntervalSince(Date())

        if timeRemaining <= 0 {
            return "⏱ expired"
        }

        let minutesRemaining = Int(timeRemaining / Double(secondsPerMinute))
        let hours = minutesRemaining / minutesPerHour
        let minutes = minutesRemaining % minutesPerHour

        return "⏱ " + formatTimeComponents(hours: hours, minutes: minutes)
    }

    func formatTimeComponents(hours: Int, minutes: Int) -> String {
        if hours == 0 {
            return "\(minutes)m"
        } else if minutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }

    private func findActiveBillingWindow() -> BillingWindow? {
        let allSessions = sessionAnalyzer.getAllRecentSessions(
            billingWindowHours: billingWindowHours,
            secondsPerHour: secondsPerHour
        )
        let windows = groupSessionsIntoWindows(allSessions)
        return windows.first { $0.isActive }
    }

    private func groupSessionsIntoWindows(_ sessions: [SessionData]) -> [BillingWindow] {
        guard !sessions.isEmpty else { return [] }

        var windows: [BillingWindow] = []
        var currentWindowSessions: [SessionData] = []
        var windowStartTime = sessions[0].startTime

        for session in sessions {
            let timeDifference = session.startTime.timeIntervalSince(windowStartTime)
            let hoursAfterStart = timeDifference / Double(secondsPerHour)

            if hoursAfterStart < Double(billingWindowHours) {
                currentWindowSessions.append(session)
            } else {
                if !currentWindowSessions.isEmpty {
                    windows.append(createBillingWindow(startTime: windowStartTime, sessions: currentWindowSessions))
                }
                currentWindowSessions = [session]
                windowStartTime = session.startTime
            }
        }

        if !currentWindowSessions.isEmpty {
            windows.append(createBillingWindow(startTime: windowStartTime, sessions: currentWindowSessions))
        }

        return windows
    }

    private func createBillingWindow(startTime: Date, sessions: [SessionData]) -> BillingWindow {
        let endTime = startTime.addingTimeInterval(TimeInterval(billingWindowHours * secondsPerHour))
        let now = Date()
        let minutesRemaining = endTime > now ? Int((endTime.timeIntervalSince(now)) / Double(secondsPerMinute)) : nil

        return BillingWindow(
            startTime: startTime,
            endTime: endTime,
            sessions: sessions,
            minutesRemaining: minutesRemaining
        )
    }
}