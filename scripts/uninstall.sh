#!/bin/bash
#
# S3Hero Uninstall Script
#
# This script removes S3Hero from your system.
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

CONFIG_DIR="$HOME/.s3hero"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   S3Hero Uninstaller${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Find Python command
python_cmd=""
for cmd in python3 python; do
    if command -v "$cmd" &> /dev/null; then
        python_cmd="$cmd"
        break
    fi
done

if [ -n "$python_cmd" ]; then
    # Uninstall via pip
    print_info "Uninstalling s3hero package..."
    "$python_cmd" -m pip uninstall -y s3hero 2>/dev/null || true
    print_success "Package uninstalled"
fi

# Ask about config
if [ -d "$CONFIG_DIR" ]; then
    echo ""
    read -p "Remove configuration files in $CONFIG_DIR? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$CONFIG_DIR"
        print_success "Removed configuration files"
    else
        print_info "Configuration files preserved"
    fi
fi

echo ""
print_success "S3Hero has been uninstalled"
print_info "You may need to remove the PATH entry from your shell config file manually"
echo ""
