#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLI_NAME="practice_cli"
GITHUB_REPO="Jangidyogesh12/practice_cli"
INSTALL_DIR="/usr/local/bin"
DATA_DIR="/usr/local/share/practice_cli"

# Functions
print_info() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_step() {
    echo -e "${BLUE}→${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS="linux";;
        Darwin*)    OS="macos";;
        MINGW*|MSYS*|CYGWIN*) OS="windows";;
        *)          print_error "Unsupported OS: $(uname -s)"; exit 1;;
    esac
    print_info "Detected OS: $OS"
}

# Check if Node.js is installed
check_nodejs() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v)
        print_info "Node.js already installed: $NODE_VERSION"
        return 0
    else
        return 1
    fi
}

# Install Node.js
install_nodejs() {
    print_step "Installing Node.js..."
    
    if [ "$OS" = "macos" ]; then
        if ! command -v brew &> /dev/null; then
            print_error "Homebrew required. Install from: https://brew.sh"
            exit 1
        fi
        brew install node || print_warning "Node.js installation may have issues, attempting to continue..."
    elif [ "$OS" = "linux" ]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update -qq 2>/dev/null || true
            sudo apt-get install -y nodejs npm 2>/dev/null || print_warning "apt-get installation may have issues"
        elif command -v yum &> /dev/null; then
            sudo yum install -y nodejs npm 2>/dev/null || print_warning "yum installation may have issues"
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm nodejs npm 2>/dev/null || print_warning "pacman installation may have issues"
        else
            print_error "No supported package manager found. Please install Node.js manually from https://nodejs.org/"
            exit 1
        fi
    elif [ "$OS" = "windows" ]; then
        print_error "Please install Node.js from https://nodejs.org/ and run this script again"
        exit 1
    fi
    
    if ! command -v node &> /dev/null; then
        print_error "Failed to install Node.js. Please install manually from https://nodejs.org/"
        exit 1
    fi
    print_info "Node.js installed: $(node -v)"
}

# Download latest release
download_release() {
    print_step "Downloading latest release from GitHub..."
    
    LATEST=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" 2>/dev/null)
    
    if echo "$LATEST" | grep -q "Not Found"; then
        print_error "No releases found. Please create a release on GitHub."
        print_info "Visit: https://github.com/$GITHUB_REPO/releases"
        exit 1
    fi
    
    VERSION=$(echo "$LATEST" | grep '"tag_name"' | head -1 | sed -E 's/.*"v?([^"]+)".*/\1/')
    
    # Try to get tar.gz release
    DOWNLOAD_URL=$(echo "$LATEST" | grep '"browser_download_url"' | grep -E '\.(tar\.gz|zip)' | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$DOWNLOAD_URL" ]; then
        # If no release found, build from source using GitHub clone
        print_step "No binary release found, downloading source from main branch..."
        TEMP_DIR=$(mktemp -d)
        trap "rm -rf $TEMP_DIR" EXIT
        
        cd "$TEMP_DIR"
        git clone --depth 1 --branch main "https://github.com/$GITHUB_REPO.git" repo 2>/dev/null || {
            print_error "Failed to clone repository"
            exit 1
        }
        cd repo
        
        pnpm install --frozen-lockfile 2>/dev/null || npm install 2>/dev/null || {
            print_error "Failed to install dependencies"
            exit 1
        }
        
        pnpm build 2>/dev/null || npm run build 2>/dev/null || {
            print_error "Failed to build project"
            exit 1
        }
        
        RELEASE_DIR="$TEMP_DIR/repo"
    else
        print_info "Downloading version: $VERSION"
        TEMP_DIR=$(mktemp -d)
        trap "rm -rf $TEMP_DIR" EXIT
        
        curl -fsSL -o "$TEMP_DIR/release.tar.gz" "$DOWNLOAD_URL" || {
            print_error "Failed to download release"
            exit 1
        }
        
        tar -xzf "$TEMP_DIR/release.tar.gz" -C "$TEMP_DIR" || {
            print_error "Failed to extract release"
            exit 1
        }
        
        # Find the extracted directory
        RELEASE_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -not -name "." | head -1)
        if [ -z "$RELEASE_DIR" ]; then
            RELEASE_DIR="$TEMP_DIR"
        fi
    fi
    
    if [ ! -f "$RELEASE_DIR/.dist/index.js" ] && [ ! -d "$RELEASE_DIR/.dist" ]; then
        print_error "Invalid release format. Expected .dist/index.js"
        exit 1
    fi
    
    print_info "Downloaded successfully"
}

# Create executable wrapper
create_wrapper() {
    print_step "Creating executable wrapper..."
    
    cat > "$TEMP_DIR/practice_cli" << 'WRAPPER'
#!/bin/bash
# Wrapper for practice_cli
CLI_DIR="/usr/local/share/practice_cli"
exec node "$CLI_DIR/.dist/index.js" "$@"
WRAPPER
    
    chmod +x "$TEMP_DIR/practice_cli"
    print_info "Wrapper created"
}

# Install files
install_files() {
    print_step "Installing to system..."
    
    # Create shared data directory if needed
    if [ ! -d "$DATA_DIR" ]; then
        sudo mkdir -p "$DATA_DIR"
    fi
    
    # Copy the compiled .dist folder
    if [ -d "$RELEASE_DIR/.dist" ]; then
        sudo cp -r "$RELEASE_DIR/.dist" "$DATA_DIR/"
        print_info "Installed CLI files"
    fi
    
    # Copy node_modules if they exist
    if [ -d "$RELEASE_DIR/node_modules" ]; then
        sudo cp -r "$RELEASE_DIR/node_modules" "$DATA_DIR/"
        print_info "Installed dependencies"
    else
        # Install dependencies
        print_step "Installing Node.js dependencies..."
        sudo cp "$RELEASE_DIR/package.json" "$DATA_DIR/" 2>/dev/null || true
        sudo cp "$RELEASE_DIR/package-lock.json" "$DATA_DIR/" 2>/dev/null || true
        
        # Install dependencies (requires write access to DATA_DIR)
        if [ -f "$DATA_DIR/package.json" ]; then
            cd "$DATA_DIR"
            sudo npm install --omit=dev --silent
            cd -
            print_info "Dependencies installed"
        fi
    fi
    
    # Copy the wrapper script
    sudo cp "$TEMP_DIR/practice_cli" "$INSTALL_DIR/practice_cli"
    sudo chmod +x "$INSTALL_DIR/practice_cli"
    print_info "Executable installed to $INSTALL_DIR/practice_cli"
}

# Verify installation
verify_installation() {
    print_step "Verifying installation..."
    
    if command -v practice_cli &> /dev/null; then
        if practice_cli --help &> /dev/null || practice_cli 2>&1 | grep -q "Usage\|Options\|Commands"; then
            print_info "Installation verified successfully!"
            return 0
        fi
    fi
    
    print_warning "Installation complete, but verification had issues"
    print_info "Try running: practice_cli --help"
    return 0
}

# Main
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  ${GREEN}$CLI_NAME${BLUE} Installation Script  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
    echo ""
    
    detect_os
    
    # Check and install Node.js if needed
    if ! check_nodejs; then
        install_nodejs
    fi
    
    # Download release/source
    download_release
    
    # Create and install wrapper
    create_wrapper
    install_files
    
    # Verify
    verify_installation
    
    echo ""
    print_info "Installation complete!"
    echo -e "${GREEN}You can now run: ${BLUE}practice_cli${NC}"
    echo ""
}

main "$@"
