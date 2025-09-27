import Foundation

// MARK: - JSON Input Models

struct ClaudeCodeSession: Codable {
    let sessionId: String
    let cwd: String
    let model: ModelInfo
    let cost: CostInfo?
    let workspace: WorkspaceInfo?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case cwd
        case model
        case cost
        case workspace
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

struct CostInfo: Codable {
    let totalDurationMs: Int?

    enum CodingKeys: String, CodingKey {
        case totalDurationMs = "total_duration_ms"
    }
}

struct WorkspaceInfo: Codable {
    let currentDir: String?
    let projectDir: String?

    enum CodingKeys: String, CodingKey {
        case currentDir = "current_dir"
        case projectDir = "project_dir"
    }
}

// MARK: - Internal Data Models

struct SessionData {
    let id: String
    let startTime: Date
}

struct BillingWindow {
    let startTime: Date
    let endTime: Date
    let sessions: [SessionData]
    let minutesRemaining: Int?

    var isActive: Bool {
        guard let remaining = minutesRemaining else { return false }
        return remaining > 0
    }
}