import Foundation

struct ModelManager {

    // Model name mappings
    private let modelNameMappings = [
        "sonnet": (contains45: "Sonnet 4.5", contains4: "Sonnet 4.0", contains35: "Sonnet 3.5", fallback: "Sonnet"),
        "haiku": (contains45: "Haiku", contains4: "Haiku", contains35: "Haiku", fallback: "Haiku"),
        "opus": (contains45: "Opus", contains4: "Opus", contains35: "Opus", fallback: "Opus")
    ]

    func formatModelName(_ model: ModelInfo) -> String {
        return model.displayName.isEmpty ? formatModelNameFromId(model.id) : model.displayName
    }

    private func formatModelNameFromId(_ model: String) -> String {
        for (modelType, names) in modelNameMappings {
            if model.contains(modelType) {
                if model.contains("4-5") || model.contains("4.5") {
                    return names.contains45
                } else if model.contains("4") {
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