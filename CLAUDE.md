# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Swift 6 terminal application that generates a single-line statusline for Claude Code. All displayed values come directly from the JSON input — no file scanning or external calculation required.

## Development Commands

### Build Commands
```bash
# Debug build for development
swift build

# Release build for production/installation
swift build --configuration release

# Built executables are located at:
# Debug: ./.build/arm64-apple-macosx/debug/claude-code-statusline
# Release: ./.build/release/claude-code-statusline
```

### Testing
```bash
# Run comprehensive test scenarios
./test-statusline.sh

# Manual testing with JSON input
echo '{"session_id": "test", "cwd": "/path", "model": {"id": "claude-sonnet-4-6", "display_name": "Sonnet 4.6"}, "context_window": {"context_window_size": 200000}}' | swift run
```

### Installation
```bash
./install.sh
```

## Architecture

### Core Components

- **StatuslineGenerator**: Orchestrator — reads JSON, coordinates managers, assembles output
- **GitManager**: Runs `git rev-parse` and `git status --porcelain` to get branch and status indicators
- **ModelManager**: Uses `display_name` or falls back to parsing the model ID
- **SessionAnalyzer**: Formats context token counts and percentage
- **TimeManager**: Formats Unix timestamps into human-readable countdowns

### Output Format

```
Wanderbuch [codex/main] | Sonnet 4.6 | 58% (115.4k/200k) | 5h: 35% (3h 37m) | 7d: 41% (6d 11h)
```

All sections joined by ` | `. Rate limit sections omitted when absent.

### Color Scheme

- **Blue**: Project name and git status
- **Magenta**: Model name
- **Green / Yellow / Red**: Context and rate limit sections, threshold-colored by usage %:
  - <70% → Green
  - 70–89% → Yellow
  - 90%+ → Red

### Input Fields Used

| Field | Usage |
|-------|-------|
| `cwd` | Project name extraction + git commands |
| `model.display_name` / `model.id` | Model name formatting |
| `context_window.context_window_size` | Context window denominator |
| `context_window.current_usage.*` | Context token counts |
| `rate_limits.five_hour.used_percentage` | 5h window usage % |
| `rate_limits.five_hour.resets_at` | Unix timestamp for 5h countdown |
| `rate_limits.seven_day.used_percentage` | 7-day window usage % |
| `rate_limits.seven_day.resets_at` | Unix timestamp for 7-day countdown |

`rate_limits` is optional. Each limit is shown independently and omitted when its field is absent.

## Platform Requirements

- Swift 6.0+
- macOS 13.0+
- Git (for repository detection)
- StrictConcurrency enabled for thread safety

## Input/Output Format

Expects JSON on stdin with structure defined in `Models.swift`. Falls back to "Claude Code" on invalid input.
