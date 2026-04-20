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
    
    # Detect Custom Global Rules Directory
    CUSTOM_RULES_DIR="$HOME/Documents/Cline/Rules"
    GLOBAL_RULES_DEST="$CLINE_DIR/superpowers-rules.md"
    
    if [ -d "$CUSTOM_RULES_DIR" ]; then
        GLOBAL_RULES_DEST="$CUSTOM_RULES_DIR/superpowers-rules.md"
        echo -e "${BLUE}Custom Rules Dir detected:${NC} $CUSTOM_RULES_DIR"
    fi
    
    echo -e "${BLUE}Global Skills Folder:${NC} $SKILLS_DIR"
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

# 4. Set up rules
TEMPLATE_FILE="$SUPERPOWERS_DIR/.cline/clinerules-template.md"

setup_rules_file() {
    local target_path="$1"
    echo -e "${BLUE}Injecting rules into $target_path...${NC}"
    if [ -f "$target_path" ]; then
        if grep -q "Superpowers for Cline" "$target_path"; then
            echo -e "${YELLOW}  - Already contains Superpowers instructions. Skipping.${NC}"
        else
            echo -e "\n\n" >> "$target_path"
            cat "$TEMPLATE_FILE" >> "$target_path"
            echo -e "  - Appended Superpowers to ${GREEN}$(basename "$target_path")${NC}"
        fi
    else
        cp "$TEMPLATE_FILE" "$target_path"
        echo -e "  - Created new ${GREEN}$(basename "$target_path")${NC}"
    fi
}

if [ "$INSTALL_GLOBAL" = true ]; then
    # Save a copy of the rules to the detected global destination
    cp "$TEMPLATE_FILE" "$GLOBAL_RULES_DEST"
    echo -e "${BLUE}Rules saved to:${NC} ${GREEN}$GLOBAL_RULES_DEST${NC}"
    
    # If the user is currently in a project, also create a local .clinerules
    if [[ "$TARGET_DIR" != "$SUPERPOWERS_DIR" && "$TARGET_DIR" != "$HOME" ]]; then
        setup_rules_file "$TARGET_DIR/.clinerules"
    fi

    echo -e "\n${YELLOW}[Global Rules Applied]${NC}"
    echo -e "  Rules have been placed in: ${BLUE}$GLOBAL_RULES_DEST${NC}"
    echo -e "  If Cline is configured to monitor this directory, it should be active."
    echo -e "  Otherwise, copy the content into: ${BLUE}Cline Settings -> Custom Instructions${NC}"
else
    setup_rules_file "$TARGET_DIR/.clinerules"
fi

echo -e "\n${GREEN}[Success]${NC} Superpowers have been successfully ported to Cline!"
echo -e "  - Please restart the Cline session or type 'refresh' to activate."
echo -e "  - Full documentation: ${BLUE}$SUPERPOWERS_DIR/.cline/INSTALL.md${NC}"
