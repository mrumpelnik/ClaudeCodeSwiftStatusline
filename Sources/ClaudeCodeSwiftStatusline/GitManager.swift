import Foundation

struct GitManager {

    func formatPathWithBranch(_ workingDirectory: String) -> String {
        let projectName = URL(fileURLWithPath: workingDirectory).lastPathComponent
        let branch = getGitBranch(at: workingDirectory)
        let gitStatus = getGitStatus(at: workingDirectory)

        if branch.isEmpty {
            return projectName
        } else if gitStatus.isEmpty {
            return "\(projectName) [\(branch)]"
        } else {
            return "\(projectName) [\(branch) \(gitStatus)]"
        }
    }

    private func getGitBranch(at path: String) -> String {
        return runGitCommand(at: path, arguments: ["rev-parse", "--abbrev-ref", "HEAD"]) ?? ""
    }

    private func getGitStatus(at path: String) -> String {
        guard let output = runGitCommand(at: path, arguments: ["status", "--porcelain"]) else {
            return ""
        }
        return parseGitStatusOutput(output)
    }

    private func parseGitStatusOutput(_ output: String) -> String {
        guard !output.isEmpty else { return "" }

        let lines = output.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var counts = (staged: 0, modified: 0, untracked: 0)

        for line in lines {
            guard line.count >= 2 else { continue }

            let indexStatus = line.prefix(1)
            let workingTreeStatus = line.dropFirst(1).prefix(1)

            if indexStatus != " " && indexStatus != "?" {
                counts.staged += 1
            }

            if workingTreeStatus == "M" || workingTreeStatus == "D" {
                counts.modified += 1
            } else if indexStatus == "?" {
                counts.untracked += 1
            }
        }

        let statusParts = [
            counts.staged > 0 ? "+\(counts.staged)" : nil,
            counts.modified > 0 ? "~\(counts.modified)" : nil,
            counts.untracked > 0 ? "?\(counts.untracked)" : nil
        ].compactMap { $0 }

        return statusParts.joined(separator: " ")
    }

    private func runGitCommand(at path: String, arguments: [String]) -> String? {
        let process = Process()
        process.launchPath = "/usr/bin/git"
        process.arguments = ["-C", path] + arguments
        process.standardError = Pipe()

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            return nil
        }

        return nil
    }
}