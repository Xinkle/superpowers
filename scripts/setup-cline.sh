#!/bin/bash

# setup-cline.sh - Port Superpowers to Cline (One-Click Installer)
# Usage: Run this script from the root of your target project.

# Color constants
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Identify Superpowers repository location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPERPOWERS_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="$(pwd)"

echo -e "${BLUE}[Superpowers for Cline]${NC} Initializing installation..."
echo -e "${BLUE}Superpowers Repo:${NC} $SUPERPOWERS_DIR"
echo -e "${BLUE}Target Project:${NC} $TARGET_DIR"

# 2. Create .cline/skills/ directory
CLINE_DIR="$TARGET_DIR/.cline"
SKILLS_DIR="$CLINE_DIR/skills"

mkdir -p "$SKILLS_DIR"

# 3. Create Symlinks for each skill
echo -e "${BLUE}Linking skills...${NC}"
for skill_path in "$SUPERPOWERS_DIR/skills"/*; do
    if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        target_link="$SKILLS_DIR/$skill_name"
        
        # Remove existing symlink or file if it exists to ensure idempotent behavior
        rm -rf "$target_link"
        
        # Create a relative symlink for better portability within the environment
        ln -s "$skill_path" "$target_link"
        echo -e "  - Linked ${GREEN}$skill_name${NC}"
    fi
done

# 4. Set up .clinerules
CLINERULES_FILE="$TARGET_DIR/.clinerules"
TEMPLATE_FILE="$SUPERPOWERS_DIR/.cline/clinerules-template.md"

if [ -f "$TEMPLATE_FILE" ]; then
    echo -e "${BLUE}Injecting .clinerules...${NC}"
    
    # Check if .clinerules already exists
    if [ -f "$CLINERULES_FILE" ]; then
        # Append if not already present
        if grep -q "Superpowers for Cline" "$CLINERULES_FILE"; then
            echo -e "${YELLOW}  - .clinerules already contains Superpowers instructions. Skipping append.${NC}"
        else
            echo -e "\n\n" >> "$CLINERULES_FILE"
            cat "$TEMPLATE_FILE" >> "$CLINERULES_FILE"
            echo -e "  - Appended Superpowers to existing ${GREEN}.clinerules${NC}"
        fi
    else
        cp "$TEMPLATE_FILE" "$CLINERULES_FILE"
        echo -e "  - Created new ${GREEN}.clinerules${NC}"
    fi
else
    echo -e "${RED}[Error]${NC} clinerules-template.md not found in $SUPERPOWERS_DIR/.cline/"
    exit 1
fi

echo -e "\n${GREEN}[Success]${NC} Superpowers have been successfully ported to Cline!"
echo -e "  - Please restart the Cline session or type 'refresh' to activate."
echo -e "  - Full documentation: ${BLUE}$SUPERPOWERS_DIR/.cline/INSTALL.md${NC}"
