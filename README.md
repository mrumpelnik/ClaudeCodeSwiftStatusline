# Claude Code Swift Statusline

A Swift 6 terminal application that generates a concise statusline for Claude Code, displaying session information, project context, and billing window status.

## Features

- **Project & Git Status**: Shows project name with git branch and status indicators
- **Billing Window**: Time remaining in the 5-hour billing window
- **Model & Context Usage**: Displays Claude model name, context percentage, and token count
- **Session Activity**: Session duration and unique session identifier

## Output Format

```
ClaudeCodeSwiftStatusline [main +1 ~1 ?3] | ⏱ 4h 7m | ⛁ Sonnet 4.0 • 71.2k (35%) | ⚡5m • da5a14c3
```

The statusline flows in four logical sections:

### 1. Project & Git Status (Blue)
`ClaudeCodeSwiftStatusline [main +1 ~1 ?3]`
- **Project name**: Current directory name
- **Git branch**: Current branch in brackets
- **Git status indicators**:
  - `+N` - N staged files (ready to commit)
  - `~N` - N modified files (changes not staged)
  - `?N` - N untracked files (new files not in git)

### 2. Billing Window (Purple)
`⏱ 4h 7m`
- **Timer icon**: ⏱ indicates time-based information
- **Time remaining**: Hours and minutes left in the 5-hour billing window
- Shows `expired` when billing window has ended

### 3. Model & Context Usage (Green)
`⛁ Sonnet 4.0 • 71.2k (35%)`
- **Context icon**: ⛁ matches Claude Code's context indicator
- **Model name**: Friendly model name (Sonnet 4.0, Haiku, etc.)
- **Token count**: Formatted token count (e.g., 71.2k for 71,200 tokens)
- **Context percentage**: Percentage of context window used (shown in parentheses)

### 4. Session Activity (Yellow)
`⚡5m • da5a14c3`
- **Activity icon**: ⚡ indicates active session information
- **Session duration**: Time elapsed since session started
- **Session ID**: Shortened session identifier for reference

## Color Scheme

The statusline uses standard ANSI colors that adapt to your terminal's theme:
- **Blue → Purple → Green → Yellow** progression
- Non-bold colors for a softer, more readable appearance
- Colors automatically adjust for light/dark terminal themes

## Installation

### Quick Install (Recommended)

Use the provided installation script to build a release version and install to `~/.claude/`:

```bash
./install.sh
```

This script will:
- Build an optimized release version
- Copy the executable to `~/.claude/claude-code-statusline`
- Test the installation
- Show you the configuration to add to your settings

### Manual Installation

1. Build the executable:
   ```bash
   swift build --configuration release
   ```

2. The executable will be available at:
   ```
   ./.build/release/claude-code-statusline
   ```

3. Copy to your preferred location and update your Claude Code settings

## Configuration

Configure Claude Code to use this statusline by adding to your `.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "/path/to/claude-code-statusline",
    "padding": 0
  }
}
```

Replace `/path/to/claude-code-statusline` with the full path to your built executable.

For more information about Claude Code statusline configuration, see the [official documentation](https://docs.claude.com/en/docs/claude-code/statusline#json-input-structure).

## Testing

Use the provided test script to verify functionality with various scenarios:

```bash
./test-statusline.sh
```

This script tests:
- Basic sessions with different durations
- Different Claude models (Sonnet, Haiku)
- Legacy model ID mapping
- Context window detection (200k vs 1M)
- Error handling with invalid input
- Complex project paths

## Input Format

The application expects JSON input on stdin with the following structure:

```json
{
  "session_id": "3052185d-7d10-46b1-bb65-dc0d01b6f8cd",
  "cwd": "/Users/martin/Developer/ClaudeSessionMonitor",
  "model": {
    "id": "claude-sonnet-4-20250514",
    "display_name": "Sonnet 4.0"
  },
  "cost": {
    "total_duration_ms": 300000
  },
  "workspace": {
    "current_dir": "/Users/martin/Developer/ClaudeSessionMonitor",
    "project_dir": "/Users/martin/Developer/ClaudeSessionMonitor"
  }
}
```

## Error Handling

- Invalid JSON input → Returns "Claude Code"
- Missing fields → Falls back to sensible defaults
- Non-git repository → Shows path without branch
- Expired billing window → Shows "expired" instead of time remaining

## Requirements

- Swift 6.0+
- macOS 13.0+
- Git (for branch detection)

## Model Support

The statusline supports both modern and legacy Claude models with automatic context window detection:

### Context Window Detection
- **1M Context Models**: Models with `1m` in the ID (e.g., `claude-sonnet-4-1m`) use 1,000,000 token context
- **Standard Models**: All other models default to 200,000 token context

> **TODO**: Verify the actual naming convention for 1M context models in Claude Code - the `1m` pattern is currently based on assumption and may need adjustment when real model IDs are confirmed.

### Model Name Mapping
The statusline automatically maps Claude model identifiers to friendly display names:
- `claude-sonnet-4-*` → "Sonnet 4.0"
- `claude-3-5-sonnet-*` → "Sonnet 3.5"
- `claude-3-haiku-*` → "Haiku"
- `claude-3-opus-*` → "Opus"

Model names are taken from the `display_name` field when available, falling back to ID-based mapping for legacy support.

## Time Formatting

- Under 1 hour: `6m`, `45m`
- Over 1 hour: `1h 30m`, `2h`
- Billing window: `4h 54m left`, `expired`