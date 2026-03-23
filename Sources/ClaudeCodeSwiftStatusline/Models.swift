import Foundation

// MARK: - JSON Input Models

struct ClaudeCodeSession: Codable {
    let sessionId: String
    let cwd: String
    let model: ModelInfo
    let contextWindow: ContextWindowInfo
    let rateLimits: RateLimits?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case cwd
        case model
        case contextWindow = "context_window"
        case rateLimits = "rate_limits"
    }
}

struct ModelInfo: Codable {
    let id: String
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}


struct ContextWindowInfo: Codable {
    let contextWindowSize: Int
    let currentUsage: CurrentUsage?

    enum CodingKeys: String, CodingKey {
        case contextWindowSize = "context_window_size"
        case currentUsage = "current_usage"
    }
}

struct CurrentUsage: Codable {
    let inputTokens: Int
    let cacheCreationInputTokens: Int
    let cacheReadInputTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case cacheCreationInputTokens = "cache_creation_input_tokens"
        case cacheReadInputTokens = "cache_read_input_tokens"
    }

    var totalContextTokens: Int {
        return inputTokens + cacheCreationInputTokens + cacheReadInputTokens
    }
}

struct RateLimits: Codable {
    let fiveHour: RateLimit?
    let sevenDay: RateLimit?

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
    }
}

struct RateLimit: Codable {
    let usedPercentage: Double
    let resetsAt: TimeInterval

    enum CodingKeys: String, CodingKey {
        case usedPercentage = "used_percentage"
        case resetsAt = "resets_at"
    }
}
