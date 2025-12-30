#!/bin/bash

# Install script for Claude Code Swift Statusline
# Builds release version and installs to ~/.claude/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Claude Code Swift Statusline - Installation Script${NC}"
echo "=================================================="
echo ""

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo -e "${RED}Error: Package.swift not found. Please run this script from the project root directory.${NC}"
    exit 1
fi

# Build release version
echo -e "${YELLOW}Building release version...${NC}"
swift build --configuration release

# Check if build succeeded
RELEASE_PATH="./.build/release/claude-code-statusline"
if [ ! -f "$RELEASE_PATH" ]; then
    echo -e "${RED}Error: Release build failed. Executable not found at $RELEASE_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Release build completed successfully${NC}"

# Create ~/.claude directory if it doesn't exist
CLAUDE_DIR="$HOME/.claude"
if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${YELLOW}Creating ~/.claude directory...${NC}"
    mkdir -p "$CLAUDE_DIR"
fi

# Copy executable to ~/.claude/
INSTALL_PATH="$CLAUDE_DIR/claude-code-statusline"
echo -e "${YELLOW}Installing to $INSTALL_PATH...${NC}"
cp "$RELEASE_PATH" "$INSTALL_PATH"

# Make sure it's executable
chmod +x "$INSTALL_PATH"

# Re-sign the binary (copying invalidates the linker signature, causing Killed: 9)
codesign --force --sign - "$INSTALL_PATH" 2>/dev/null || true

echo -e "${GREEN}✓ Statusline installed successfully${NC}"

# Test the installed version
echo ""
echo -e "${YELLOW}Testing installed version...${NC}"
echo '{"session_id": "install-test", "cwd": "'$(pwd)'", "model": {"id": "claude-sonnet-4-20250514", "display_name": "Sonnet 4.0"}, "cost": {"total_duration_ms": 60000}}' | "$INSTALL_PATH"
echo ""

echo -e "${GREEN}✓ Installation completed successfully!${NC}"
echo ""
echo -e "${BLUE}Configuration Instructions:${NC}"
echo "Add the following to your ~/.claude/settings.json:"
echo ""
echo "{"
echo "  \"statusLine\": {"
echo "    \"type\": \"command\","
echo "    \"command\": \"$INSTALL_PATH\","
echo "    \"padding\": 0"
echo "  }"
echo "}"
echo ""
echo -e "${BLUE}File locations:${NC}"
echo "• Executable: $INSTALL_PATH"
echo "• Configuration: ~/.claude/settings.json"
echo ""
echo -e "${GREEN}Ready to use with Claude Code!${NC}"