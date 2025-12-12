#!/bin/bash

# Test script for Claude Code Swift Statusline
# This script tests various scenarios to demonstrate the statusline functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Build the statusline first
echo -e "${BLUE}Building statusline...${NC}"
swift build
echo ""

STATUSLINE_PATH="./.build/arm64-apple-macosx/debug/claude-code-statusline"

if [ ! -f "$STATUSLINE_PATH" ]; then
    echo -e "${RED}Error: Statusline executable not found at $STATUSLINE_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}Testing Claude Code Swift Statusline${NC}"
echo "=================================================="
echo ""

# Test 1: Basic scenario
echo -e "${YELLOW}Test 1: Basic scenario${NC}"
echo "JSON: Basic session with short duration"
echo '{"session_id": "abc123", "cwd": "/Users/test/MyProject", "model": {"id": "claude-sonnet-4-20250514", "display_name": "Sonnet 4.0"}, "cost": {"total_duration_ms": 180000}, "context_window": {"total_input_tokens": 15000, "total_output_tokens": 5000, "context_window_size": 200000}}' | $STATUSLINE_PATH
echo ""

# Test 2: Longer session
echo -e "${YELLOW}Test 2: Longer session (over 1 hour)${NC}"
echo "JSON: Session running for 1.5 hours"
echo '{"session_id": "def456", "cwd": "/Users/test/LongProject", "model": {"id": "claude-sonnet-4-20250514", "display_name": "Sonnet 4.0"}, "cost": {"total_duration_ms": 5400000}, "context_window": {"total_input_tokens": 80000, "total_output_tokens": 20000, "context_window_size": 200000}}' | $STATUSLINE_PATH
echo ""

# Test 3: Haiku model
echo -e "${YELLOW}Test 3: Different model (Haiku)${NC}"
echo "JSON: Using Haiku model"
echo '{"session_id": "ghi789", "cwd": "/Users/test/HaikuProject", "model": {"id": "claude-haiku-3-0-20240307", "display_name": "Haiku"}, "cost": {"total_duration_ms": 300000}, "context_window": {"total_input_tokens": 10000, "total_output_tokens": 3000, "context_window_size": 200000}}' | $STATUSLINE_PATH
echo ""

# Test 4: Model ID without display name (tests dynamic parsing)
echo -e "${YELLOW}Test 4: Model ID without display name${NC}"
echo "JSON: Model without display_name (tests dynamic parsing)"
echo '{"session_id": "jkl012", "cwd": "/Users/test/LegacyProject", "model": {"id": "claude-sonnet-4-5-20250929", "display_name": ""}, "cost": {"total_duration_ms": 420000}, "context_window": {"total_input_tokens": 25000, "total_output_tokens": 8000, "context_window_size": 200000}}' | $STATUSLINE_PATH
echo ""

# Test 5: Very short session
echo -e "${YELLOW}Test 5: Very short session${NC}"
echo "JSON: Session under 1 minute"
echo '{"session_id": "mno345", "cwd": "/Users/test/QuickProject", "model": {"id": "claude-sonnet-4-20250514", "display_name": "Sonnet 4.0"}, "cost": {"total_duration_ms": 30000}, "context_window": {"total_input_tokens": 2000, "total_output_tokens": 500, "context_window_size": 200000}}' | $STATUSLINE_PATH
echo ""

# Test 6: No duration (new session)
echo -e "${YELLOW}Test 6: New session (no duration)${NC}"
echo "JSON: Session just started"
echo '{"session_id": "pqr678", "cwd": "/Users/test/NewProject", "model": {"id": "claude-sonnet-4-20250514", "display_name": "Sonnet 4.0"}, "context_window": {"total_input_tokens": 100, "total_output_tokens": 50, "context_window_size": 200000}}' | $STATUSLINE_PATH
echo ""

# Test 7: Invalid JSON
echo -e "${YELLOW}Test 7: Invalid JSON (error handling)${NC}"
echo "JSON: Malformed JSON input"
echo '{"invalid": json}' | $STATUSLINE_PATH
echo ""

# Test 8: Complex project path
echo -e "${YELLOW}Test 8: Complex project path${NC}"
echo "JSON: Project with complex path"
echo '{"session_id": "stu901", "cwd": "/Users/developer/Projects/MyAwesome-App_v2.0", "model": {"id": "claude-sonnet-4-20250514", "display_name": "Sonnet 4.0"}, "cost": {"total_duration_ms": 1800000}, "context_window": {"total_input_tokens": 45000, "total_output_tokens": 12000, "context_window_size": 200000}}' | $STATUSLINE_PATH
echo ""

# Test 9: 1M Context Model
echo -e "${YELLOW}Test 9: 1M Context Model${NC}"
echo "JSON: Model with 1M context window"
echo '{"session_id": "xyz999", "cwd": "/Users/test/ContextProject", "model": {"id": "claude-opus-4-5-20251101", "display_name": ""}, "cost": {"total_duration_ms": 900000}, "context_window": {"total_input_tokens": 500000, "total_output_tokens": 100000, "context_window_size": 1000000}}' | $STATUSLINE_PATH
echo ""

echo -e "${GREEN}All tests completed!${NC}"
echo ""
echo -e "${BLUE}Color scheme: Blue → Purple → Green → Yellow${NC}"
echo "1. Blue: Project & Git Status"
echo "2. Purple: Billing Window Time"
echo "3. Green: Model & Context Usage"
echo "4. Yellow: Session Activity"