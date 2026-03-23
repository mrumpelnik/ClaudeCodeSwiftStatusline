import Foundation

struct TimeManager {

    private let minutesPerHour = 60

    func formatTimeUntil(_ unixTimestamp: TimeInterval) -> String {
        let secondsUntil = max(0, unixTimestamp - Date().timeIntervalSince1970)
        let totalMinutes = Int(secondsUntil / 60)
        let days = totalMinutes / (minutesPerHour * 24)
        if days > 0 {
            let hours = (totalMinutes % (minutesPerHour * 24)) / minutesPerHour
            return hours == 0 ? "\(days)d" : "\(days)d \(hours)h"
        }
        return formatTimeComponents(hours: totalMinutes / minutesPerHour, minutes: totalMinutes % minutesPerHour)
    }

    private func formatTimeComponents(hours: Int, minutes: Int) -> String {
        if hours == 0 {
            return "\(minutes)m"
        } else if minutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
}
