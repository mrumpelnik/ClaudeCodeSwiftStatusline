import Foundation

struct SessionAnalyzer {

    func formatContextPercent(contextWindowSize: Int, currentUsage: CurrentUsage?) -> String {
        let tokenCount = currentUsage?.totalContextTokens ?? 0
        let percent = Int((Double(tokenCount) / Double(contextWindowSize) * 100.0).rounded())
        return "\(percent)% (\(formatTokenCount(tokenCount))/\(formatContextWindowSize(contextWindowSize)))"
    }

    private func formatTokenCount(_ tokens: Int) -> String {
        if tokens >= 1000 {
            return String(format: "%.1fk", Double(tokens) / 1000.0)
        } else {
            return "\(tokens)"
        }
    }

    private func formatContextWindowSize(_ size: Int) -> String {
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
}
