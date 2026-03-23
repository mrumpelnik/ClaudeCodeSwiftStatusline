#!/bin/bash

# Test script for Claude Code Swift Statusline

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# Unix timestamp ~2h 15m from now for reset time tests
RESET_SOON=$(( $(date +%s) + 8100 ))
# Unix timestamp ~4h 30m from now
RESET_FAR=$(( $(date +%s) + 16200 ))

# Test 1: Basic session with rate limits (green thresholds)
echo -e "${YELLOW}Test 1: Basic session, low usage (green)${NC}"
echo '{"session_id": "abc123def456", "cwd": "/Users/test/MyProject", "model": {"id": "claude-sonnet-4-6", "display_name": "Sonnet 4.6"}, "cost": {"total_duration_ms": 180000}, "context_window": {"context_window_size": 200000, "current_usage": {"input_tokens": 15000, "cache_creation_input_tokens": 2000, "cache_read_input_tokens": 8000}}, "rate_limits": {"five_hour": {"used_percentage": 23.5, "resets_at": '"$RESET_FAR"'}}}' | $STATUSLINE_PATH
echo ""

# Test 2: High context usage (yellow threshold ~75%)
echo -e "${YELLOW}Test 2: High context usage (yellow ~75%)${NC}"
echo '{"session_id": "def456ghi789", "cwd": "/Users/test/LongProject", "model": {"id": "claude-sonnet-4-6", "display_name": "Sonnet 4.6"}, "cost": {"total_duration_ms": 5400000}, "context_window": {"context_window_size": 200000, "current_usage": {"input_tokens": 140000, "cache_creation_input_tokens": 5000, "cache_read_input_tokens": 5000}}, "rate_limits": {"five_hour": {"used_percentage": 75.0, "resets_at": '"$RESET_SOON"'}}}' | $STATUSLINE_PATH
echo ""

# Test 3: Critical usage (red threshold >90%)
echo -e "${YELLOW}Test 3: Critical usage (red >90%)${NC}"
echo '{"session_id": "ghi789jkl012", "cwd": "/Users/test/CriticalProject", "model": {"id": "claude-opus-4-6", "display_name": "Opus 4"}, "cost": {"total_duration_ms": 14400000}, "context_window": {"context_window_size": 200000, "current_usage": {"input_tokens": 185000, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0}}, "rate_limits": {"five_hour": {"used_percentage": 92.0, "resets_at": '"$RESET_SOON"'}}}' | $STATUSLINE_PATH
echo ""

# Test 4: No rate_limits field (Pro/Max field absent)
echo -e "${YELLOW}Test 4: No rate_limits (field absent)${NC}"
echo '{"session_id": "jkl012mno345", "cwd": "/Users/test/NoLimitsProject", "model": {"id": "claude-haiku-4-5-20251001", "display_name": "Haiku 4"}, "cost": {"total_duration_ms": 300000}, "context_window": {"context_window_size": 200000, "current_usage": {"input_tokens": 10000, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0}}}' | $STATUSLINE_PATH
echo ""

# Test 5: 1M context window
echo -e "${YELLOW}Test 5: 1M context window${NC}"
echo '{"session_id": "mno345pqr678", "cwd": "/Users/test/LargeContext", "model": {"id": "claude-opus-4-6", "display_name": "Opus 4"}, "cost": {"total_duration_ms": 900000}, "context_window": {"context_window_size": 1000000, "current_usage": {"input_tokens": 450000, "cache_creation_input_tokens": 30000, "cache_read_input_tokens": 20000}}, "rate_limits": {"five_hour": {"used_percentage": 41.2, "resets_at": '"$RESET_FAR"'}}}' | $STATUSLINE_PATH
echo ""

# Test 6: No current_usage (session just started)
echo -e "${YELLOW}Test 6: No current_usage (new session)${NC}"
echo '{"session_id": "pqr678stu901", "cwd": "/Users/test/NewProject", "model": {"id": "claude-sonnet-4-6", "display_name": "Sonnet 4.6"}, "context_window": {"context_window_size": 200000}, "rate_limits": {"five_hour": {"used_percentage": 5.0, "resets_at": '"$RESET_FAR"'}}}' | $STATUSLINE_PATH
echo ""

# Test 7: Model ID without display_name (dynamic parsing)
echo -e "${YELLOW}Test 7: Model ID without display_name${NC}"
echo '{"session_id": "stu901vwx234", "cwd": "/Users/test/LegacyProject", "model": {"id": "claude-sonnet-4-5-20250929", "display_name": ""}, "cost": {"total_duration_ms": 420000}, "context_window": {"context_window_size": 200000, "current_usage": {"input_tokens": 25000, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0}}}' | $STATUSLINE_PATH
echo ""

# Test 8: Invalid JSON (error handling)
echo -e "${YELLOW}Test 8: Invalid JSON${NC}"
echo '{"invalid": json}' | $STATUSLINE_PATH
echo ""

echo -e "${GREEN}All tests completed!${NC}"
echo ""
echo -e "${BLUE}Color thresholds: green <70% / yellow 70-89% / red 90%+${NC}"
echo "Line 1: Project [branch] | Model context usage"
echo "Line 2: Session ID | Duration rate-limit% reset-time"
