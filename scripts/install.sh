#!/bin/bash
#
# S3Hero Installation Script
# 
# This script installs S3Hero on Linux and macOS systems.
# It automatically detects your OS and architecture.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/aravindgopall/s3hero/main/scripts/install.sh | bash
#
# Or download and run:
#   chmod +x install.sh
#   ./install.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO="aravindgopall/s3hero"
INSTALL_DIR="${S3HERO_INSTALL_DIR:-$HOME/.local/bin}"
VENV_DIR="${S3HERO_VENV_DIR:-$HOME/.s3hero/venv}"
MIN_PYTHON_VERSION="3.8"

# Print functions
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}   S3Hero Installer${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Detect OS and architecture
detect_os() {
    local os=""
    local arch=""
    
    case "$(uname -s)" in
        Linux*)     os="linux";;
        Darwin*)    os="darwin";;
        *)          print_error "Unsupported operating system: $(uname -s)"; exit 1;;
    esac
    
    case "$(uname -m)" in
        x86_64)     arch="amd64";;
        aarch64)    arch="arm64";;
        arm64)      arch="arm64";;
        *)          arch="$(uname -m)";;
    esac
    
    echo "${os}-${arch}"
}

# Check if Python is installed and meets minimum version
check_python() {
    local python_cmd=""
    
    # Try different Python commands
    for cmd in python3 python; do
        if command -v "$cmd" &> /dev/null; then
            local version=$("$cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
            if [ -n "$version" ]; then
                local major=$(echo "$version" | cut -d. -f1)
                local minor=$(echo "$version" | cut -d. -f2)
                local min_major=$(echo "$MIN_PYTHON_VERSION" | cut -d. -f1)
                local min_minor=$(echo "$MIN_PYTHON_VERSION" | cut -d. -f2)
                
                if [ "$major" -gt "$min_major" ] || ([ "$major" -eq "$min_major" ] && [ "$minor" -ge "$min_minor" ]); then
                    python_cmd="$cmd"
                    break
                fi
            fi
        fi
    done
    
    if [ -z "$python_cmd" ]; then
        print_error "Python $MIN_PYTHON_VERSION or higher is required but not found."
        print_info "Please install Python from https://www.python.org/downloads/"
        exit 1
    fi
    
    echo "$python_cmd"
}

# Check if pip is installed
check_pip() {
    local python_cmd="$1"
    
    if ! "$python_cmd" -m pip --version &> /dev/null; then
        print_warning "pip is not installed. Attempting to install..."
        
        # Try to install pip
        if [ "$(uname -s)" = "Darwin" ]; then
            "$python_cmd" -m ensurepip --upgrade 2>/dev/null || true
        else
            curl -fsSL https://bootstrap.pypa.io/get-pip.py | "$python_cmd" - 2>/dev/null || true
        fi
        
        if ! "$python_cmd" -m pip --version &> /dev/null; then
            print_error "Failed to install pip. Please install it manually."
            exit 1
        fi
    fi
}

# Create virtual environment
create_venv() {
    local python_cmd="$1"
    local venv_dir="$2"
    
    print_info "Creating virtual environment at $venv_dir..."
    
    # Create parent directory
    mkdir -p "$(dirname "$venv_dir")"
    
    # Remove existing venv if present
    if [ -d "$venv_dir" ]; then
        rm -rf "$venv_dir"
    fi
    
    # Create new venv
    "$python_cmd" -m venv "$venv_dir"
    
    if [ ! -f "$venv_dir/bin/activate" ]; then
        print_error "Failed to create virtual environment"
        exit 1
    fi
    
    print_success "Virtual environment created"
}

# Install s3hero in virtual environment
install_s3hero() {
    local venv_dir="$1"
    local python_venv="$venv_dir/bin/python"
    
    print_info "Installing s3hero..."
    
    # Upgrade pip
    "$python_venv" -m pip install --upgrade pip --quiet
    
    # Install from PyPI (if available) or from source
    if pip index versions s3hero &> /dev/null 2>&1; then
        "$python_venv" -m pip install s3hero --quiet
    else
        # Install from GitHub
        "$python_venv" -m pip install "git+https://github.com/${REPO}.git" --quiet 2>/dev/null || {
            # Fallback: install from current directory if running locally
            if [ -f "pyproject.toml" ]; then
                print_info "Installing from local source..."
                "$python_venv" -m pip install . --quiet
            else
                print_error "Failed to install s3hero. Please check your internet connection."
                exit 1
            fi
        }
    fi
    
    print_success "s3hero installed"
}

# Create wrapper script
create_wrapper() {
    local install_dir="$1"
    local venv_dir="$2"
    
    print_info "Creating s3hero command wrapper..."
    
    mkdir -p "$install_dir"
    
    cat > "$install_dir/s3hero" << EOF
#!/bin/bash
# S3Hero wrapper script
# Activates the virtual environment and runs s3hero

export PATH="$venv_dir/bin:\$PATH"
exec "$venv_dir/bin/python" -m s3hero.cli "\$@"
EOF
    
    chmod +x "$install_dir/s3hero"
    
    print_success "Wrapper script created at $install_dir/s3hero"
}

# Add to PATH if needed
update_path() {
    local bin_dir="$1"
    local shell_rc=""
    
    # Check if already in PATH
    if echo "$PATH" | grep -q "$bin_dir"; then
        return 0
    fi
    
    # Detect shell configuration file
    case "$SHELL" in
        */zsh)
            shell_rc="$HOME/.zshrc"
            ;;
        */bash)
            if [ -f "$HOME/.bashrc" ]; then
                shell_rc="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                shell_rc="$HOME/.bash_profile"
            fi
            ;;
        *)
            shell_rc="$HOME/.profile"
            ;;
    esac
    
    if [ -n "$shell_rc" ]; then
        # Check if PATH addition already exists
        if ! grep -q "s3hero" "$shell_rc" 2>/dev/null; then
            echo "" >> "$shell_rc"
            echo "# S3Hero CLI" >> "$shell_rc"
            echo "export PATH=\"\$PATH:$bin_dir\"" >> "$shell_rc"
            print_info "Added $bin_dir to PATH in $shell_rc"
        fi
    fi
}

# Main installation
main() {
    print_header
    
    # Detect OS
    local os_arch=$(detect_os)
    print_info "Detected: $os_arch"
    
    # Check Python
    print_info "Checking Python installation..."
    local python_cmd=$(check_python)
    local python_version=$("$python_cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')")
    print_success "Found Python $python_version ($python_cmd)"
    
    # Check pip
    check_pip "$python_cmd"
    print_success "pip is available"
    
    # Install s3hero globally
    install_s3hero "$python_cmd"
    
    # Get user bin directory
    local user_bin=$(get_user_bin_dir "$python_cmd")
    
    # Update PATH
    update_path "$user_bin"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}   Installation Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    print_info "To get started, run:"
    echo ""
    echo "    export PATH=\"\$PATH:$user_bin\""
    echo "    s3hero configure add"
    echo ""
    print_info "Or start a new terminal session and run:"
    echo ""
    echo "    s3hero --help"
    echo ""
}

# Run main
main "$@"
