import Foundation

struct ModelManager {

    // Configuration constants
    private let defaultContextWindowSize = 200_000
    private let extendedContextWindowSize = 1_000_000

    // Model name mappings
    private let modelNameMappings = [
        "sonnet": (contains4: "Sonnet 4.0", contains35: "Sonnet 3.5", fallback: "Sonnet"),
        "haiku": (contains4: "Haiku", contains35: "Haiku", fallback: "Haiku"),
        "opus": (contains4: "Opus", contains35: "Opus", fallback: "Opus")
    ]

    func formatModelName(_ model: ModelInfo) -> String {
        return model.displayName.isEmpty ? formatModelNameFromId(model.id) : model.displayName
    }

    func getContextWindowSize(for model: ModelInfo) -> Int {
        // Check model ID for 1M context indicators (e.g., "claude-sonnet-4-1m")
        // Models with "1m" in ID have 1M token context, others default to 200k
        if model.id.hasSuffix("-1m") || model.id.contains("1m") {
            return extendedContextWindowSize
        }
        return defaultContextWindowSize
    }

    private func formatModelNameFromId(_ model: String) -> String {
        for (modelType, names) in modelNameMappings {
            if model.contains(modelType) {
                if model.contains("4") {
                    return names.contains4
                } else if model.contains("3.5") {
                    return names.contains35
                } else {
                    return names.fallback
                }
            }
        }
        return model.components(separatedBy: "-").last?.capitalized ?? model
    }
}