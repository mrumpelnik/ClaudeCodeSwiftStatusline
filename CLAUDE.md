# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Swift 6 terminal application that generates a concise statusline for Claude Code, displaying session information, project context, and billing window status. The statusline provides real-time feedback about Claude sessions in a colorized format.

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
echo '{"session_id": "test", "cwd": "/path", "model": {"id": "claude-sonnet-4-20250514", "display_name": "Sonnet 4.0"}}' | swift run
```

### Installation
```bash
# Quick install to ~/.claude/ directory
./install.sh

# Manual installation steps in install.sh script
```

## Architecture

The application follows a modular architecture with specialized managers:

### Core Components

- **StatuslineGenerator**: Main orchestrator that coordinates all managers and generates the final output
- **GitManager**: Handles git repository detection, branch names, and status parsing (`+N ~N ?N` format)
- **ModelManager**: Maps Claude model IDs to friendly names and detects context window sizes
- **SessionAnalyzer**: Tracks session data, billing windows, and context usage calculations
- **TimeManager**: Formats time durations and calculates billing window remainders

### Data Flow

1. JSON input from stdin → `ClaudeCodeSession` model
2. StatuslineGenerator coordinates managers:
   - GitManager formats project path with branch/status
   - ModelManager determines model display name and context window
   - SessionAnalyzer calculates context percentage and tracks sessions
   - TimeManager formats session duration and billing window time
3. Assembles colored statusline: `Project [branch status] | ⏱ time | ⛁ Model • context | ⚡duration • sessionId`

### Model Support

- Context windows: 200k tokens (default) or 1M tokens (models with `1m` in ID)
- Model mapping: Supports both modern display names and legacy ID-based mapping
- Handles models: Sonnet 4.0, Sonnet 3.5, Haiku, Opus

### Session Management

- Tracks 5-hour billing windows across multiple sessions
- Persists session data to calculate context usage and billing time
- Groups sessions into billing windows for accurate time remaining calculations

## Platform Requirements

- Swift 6.0+
- macOS 13.0+
- Git (for repository detection)
- StrictConcurrency enabled for thread safety

## Input/Output Format

Expects JSON on stdin with structure defined in `Models.swift`. Falls back to "Claude Code" on invalid input.
Outputs ANSI-colored statusline with Blue → Purple → Green → Yellow progression.