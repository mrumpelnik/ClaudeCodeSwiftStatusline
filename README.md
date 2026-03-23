# Claude Code Swift Statusline

A Swift 6 terminal application that generates a concise statusline for Claude Code, displaying project context, model info, and rate limit status.

## Output

```
Wanderbuch [codex/main] | Sonnet 4.6 | 58% (115.4k/200k) | 5h: 35% (3h 37m) | 7d: 41% (6d 11h)
```

### Sections

- **Project name**: Current directory name with git branch in brackets
- **Git status indicators** (inside brackets):
  - `+N` — N staged files
  - `~N` — N modified files
  - `?N` — N untracked files
- **Model**: Friendly model name from JSON `display_name`
- **Context usage**: Percentage used with token counts in parentheses
- **5h / 7d rate limits**: Usage % with countdown to reset in parentheses — omitted individually when fields are absent

## Color Scheme

Colors follow green/yellow/red thresholds applied per percentage item:

| Range  | Color  |
|--------|--------|
| <70%   | Green  |
| 70–89% | Yellow |
| 90%+   | Red    |

- **Blue**: Project name and git status
- **Magenta**: Model name
- Context and rate limit sections are each colored by their respective percentage.

## Installation

### Quick Install (Recommended)

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

For more information about Claude Code statusline configuration, see the [official documentation](https://docs.claude.com/en/docs/claude-code/statusline#json-input-structure).

## Testing

```bash
./test-statusline.sh
```

This script tests:
- Low / medium / high usage thresholds (green / yellow / red)
- Sessions with and without rate limit data
- 1M context window models
- Model ID parsing without display name
- Error handling with invalid input

## Input Format

All displayed values come directly from the JSON input provided by Claude Code:

```json
{
  "session_id": "298e7f61-1339-4ab5-ace2-7b24dce84291",
  "cwd": "/Users/martin/Developer/Wanderbuch",
  "model": {
    "id": "claude-sonnet-4-6",
    "display_name": "Sonnet 4.6"
  },
  "context_window": {
    "context_window_size": 200000,
    "current_usage": {
      "input_tokens": 100000,
      "cache_creation_input_tokens": 10000,
      "cache_read_input_tokens": 5400
    }
  },
  "rate_limits": {
    "five_hour": {
      "used_percentage": 23.5,
      "resets_at": 1738425600
    },
    "seven_day": {
      "used_percentage": 41.2,
      "resets_at": 1738857600
    }
  }
}
```

`rate_limits` is only present for Claude.ai Pro/Max subscribers after the first API response. Each limit is shown independently — if only `five_hour` is present, `7d` is omitted, and vice versa.

## Error Handling

- Invalid JSON input → Returns "Claude Code"
- Missing `rate_limits` → Rate limit sections omitted
- Missing `current_usage` → Shows 0% context used
- Non-git repository → Shows project name without branch

## Requirements

- Swift 6.0+
- macOS 13.0+
- Git (for branch detection)

## Time Formatting

- Under 1 hour: `45m`
- Under 1 day: `3h 37m`
- 1 day or more: `6d 11h`
