#!/bin/bash
#
# S3Hero Installation Script
# 
# Installs S3Hero globally so you can run 's3hero' from anywhere.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kamaravichow/s3hero/main/scripts/install.sh | bash
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
print_error() { echo -e "${RED}✗${NC} $1"; }

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}   S3Hero Installer${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Find Python 3.8+
find_python() {
    for cmd in python3 python; do
        if command -v "$cmd" &> /dev/null; then
            version=$("$cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
            major=$(echo "$version" | cut -d. -f1)
            minor=$(echo "$version" | cut -d. -f2)
            if [ "$major" -ge 3 ] && [ "$minor" -ge 8 ]; then
                echo "$cmd"
                return 0
            fi
        fi
    done
    return 1
}

# Get the user bin directory where pip installs scripts
get_user_bin() {
    local python_cmd="$1"
    
    # Get user site packages bin directory
    if [ "$(uname -s)" = "Darwin" ]; then
        # macOS: ~/Library/Python/X.Y/bin
        local py_version=$("$python_cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        echo "$HOME/Library/Python/$py_version/bin"
    else
        # Linux: ~/.local/bin
        echo "$HOME/.local/bin"
    fi
}

# Add directory to PATH in shell config
add_to_path() {
    local bin_dir="$1"
    local shell_rc=""
    local path_line="export PATH=\"\$PATH:$bin_dir\""
    
    # Already in PATH?
    if [[ ":$PATH:" == *":$bin_dir:"* ]]; then
        return 0
    fi
    
    # Determine shell config file
    if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/usr/bin/bash" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            shell_rc="$HOME/.bashrc"
        else
            shell_rc="$HOME/.bash_profile"
        fi
    else
        shell_rc="$HOME/.profile"
    fi
    
    # Add to shell config if not already there
    if [ -f "$shell_rc" ]; then
        if ! grep -q "$bin_dir" "$shell_rc" 2>/dev/null; then
            echo "" >> "$shell_rc"
            echo "# S3Hero CLI" >> "$shell_rc"
            echo "$path_line" >> "$shell_rc"
            print_info "Added $bin_dir to PATH in $shell_rc"
        fi
    else
        echo "$path_line" >> "$shell_rc"
        print_info "Created $shell_rc with PATH"
    fi
    
    # Export for current session
    export PATH="$PATH:$bin_dir"
}

# Main installation
main() {
    print_header
    
    # Find Python
    print_info "Checking Python installation..."
    PYTHON=$(find_python)
    if [ -z "$PYTHON" ]; then
        print_error "Python 3.8 or higher is required"
        print_info "Install Python from https://www.python.org/downloads/"
        exit 1
    fi
    
    py_version=$("$PYTHON" --version 2>&1)
    print_success "Found $py_version"
    
    # Check pip
    if ! "$PYTHON" -m pip --version &> /dev/null; then
        print_error "pip is not installed"
        print_info "Install pip: $PYTHON -m ensurepip --upgrade"
        exit 1
    fi
    print_success "pip is available"
    
    # Get user bin directory
    USER_BIN=$(get_user_bin "$PYTHON")
    
    # Create bin directory if it doesn't exist
    mkdir -p "$USER_BIN"
    
    # Install s3hero
    print_info "Installing s3hero from PyPI..."
    if "$PYTHON" -m pip install --user --upgrade s3hero 2>&1 | grep -v "already satisfied"; then
        print_success "s3hero installed"
    else
        print_error "Failed to install s3hero"
        exit 1
    fi
    
    # Add to PATH
    add_to_path "$USER_BIN"
    
    # Verify installation
    if [ -f "$USER_BIN/s3hero" ]; then
        print_success "s3hero is ready at $USER_BIN/s3hero"
    else
        # Sometimes pip installs to a different location, try to find it
        INSTALLED_PATH=$("$PYTHON" -m pip show -f s3hero 2>/dev/null | grep "s3hero$" | head -1 | xargs -I {} dirname {} 2>/dev/null || true)
        if [ -n "$INSTALLED_PATH" ] && [ -f "$INSTALLED_PATH/s3hero" ]; then
            add_to_path "$INSTALLED_PATH"
            print_success "s3hero is ready at $INSTALLED_PATH/s3hero"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}   Installation Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Check if s3hero works now
    if command -v s3hero &> /dev/null; then
        print_success "s3hero is ready to use!"
        echo ""
        echo "    s3hero --help"
        echo "    s3hero configure add"
    else
        print_warning "Please restart your terminal or run:"
        echo ""
        echo "    source ~/.zshrc   # or ~/.bashrc"
        echo ""
        echo "Then run:"
        echo ""
        echo "    s3hero --help"
    fi
    echo ""
}

main "$@"
