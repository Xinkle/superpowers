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

# Parse arguments
INSTALL_GLOBAL=false
if [[ "$1" == "--global" || "$1" == "-g" ]]; then
    INSTALL_GLOBAL=true
fi

if [ "$INSTALL_GLOBAL" = true ]; then
    echo -e "${BLUE}[Superpowers for Cline]${NC} Initializing GLOBAL installation..."
    CLINE_DIR="$HOME/.cline"
    SKILLS_DIR="$CLINE_DIR/skills"
    echo -e "${BLUE}Global Folder:${NC} $CLINE_DIR"
else
    # Improved Root Detection: Try to find the nearest project root (.git or package.json)
    echo -e "${BLUE}[Superpowers for Cline]${NC} Initializing LOCAL installation..."
    
    # Simple root detection: look for .git, package.json or go up until /
    current_check="$TARGET_DIR"
    while [[ "$current_check" != "/" ]]; do
        if [[ -d "$current_check/.git" || -f "$current_check/package.json" ]]; then
            TARGET_DIR="$current_check"
            break
        fi
        current_check="$(dirname "$current_check")"
    done
    
    CLINE_DIR="$TARGET_DIR/.cline"
    SKILLS_DIR="$CLINE_DIR/skills"
    echo -e "${BLUE}Superpowers Repo:${NC} $SUPERPOWERS_DIR"
    echo -e "${BLUE}Target Project:${NC} $TARGET_DIR"
fi

# 2. Create skills directory
mkdir -p "$SKILLS_DIR"

# 3. Create Symlinks for each skill
echo -e "${BLUE}Linking skills...${NC}"
for skill_path in "$SUPERPOWERS_DIR/skills"/*; do
    if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        target_link="$SKILLS_DIR/$skill_name"
        
        # Remove existing symlink or file if it exists to ensure idempotent behavior
        rm -rf "$target_link"
        
        # Use absolute path for global links to avoid broken relative links
        ln -s "$skill_path" "$target_link"
        echo -e "  - Linked ${GREEN}$skill_name${NC}"
    fi
done

# 4. Set up rules (Only for Local install, or guide for global rules)
if [ "$INSTALL_GLOBAL" = false ]; then
    CLINERULES_FILE="$TARGET_DIR/.clinerules"
    TEMPLATE_FILE="$SUPERPOWERS_DIR/.cline/clinerules-template.md"

    if [ -f "$TEMPLATE_FILE" ]; then
        echo -e "${BLUE}Injecting .clinerules...${NC}"
        if [ -f "$CLINERULES_FILE" ]; then
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
    fi
else
    echo -e "\n${YELLOW}[Global Rule Tip]${NC}"
    echo -e "  To apply Superpowers globally, copy the content of:"
    echo -e "  ${BLUE}$SUPERPOWERS_DIR/.cline/clinerules-template.md${NC}"
    echo -e "  into your Cline's ${BLUE}Custom Instructions${NC} in Settings."
fi

echo -e "\n${GREEN}[Success]${NC} Superpowers have been successfully ported to Cline!"
echo -e "  - Please restart the Cline session or type 'refresh' to activate."
echo -e "  - Full documentation: ${BLUE}$SUPERPOWERS_DIR/.cline/INSTALL.md${NC}"
