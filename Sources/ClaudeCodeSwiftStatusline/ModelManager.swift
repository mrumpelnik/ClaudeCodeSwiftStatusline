import Foundation

struct ModelManager {

    func formatModelName(_ model: ModelInfo) -> String {
        return model.displayName.isEmpty ? formatModelNameFromId(model.id) : model.displayName
    }

    private func formatModelNameFromId(_ model: String) -> String {
        let components = model.split(separator: "-")

        guard components.count >= 4 else {
            return model.components(separatedBy: "-").last?.capitalized ?? model
        }

        // Format: claude-model-major-minor-date (e.g., claude-sonnet-4-5-20250929)
        let modelName = String(components[1]).capitalized
        let majorVersion = String(components[2])
        let minorVersion = String(components[3])

        return "\(modelName) \(majorVersion).\(minorVersion)"
    }
}