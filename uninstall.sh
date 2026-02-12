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

# Check if CLI is installed
check_installed() {
    if command -v $CLI_NAME &> /dev/null; then
        print_info "$CLI_NAME is installed"
        return 0
    else
        print_error "$CLI_NAME is not installed"
        exit 1
    fi
}

# Uninstall the CLI
uninstall() {
    print_step "Uninstalling $CLI_NAME..."
    
    # Remove executable
    if [ -f "$INSTALL_DIR/$CLI_NAME" ]; then
        sudo rm -f "$INSTALL_DIR/$CLI_NAME"
        print_info "Removed executable from $INSTALL_DIR/$CLI_NAME"
    fi
    
    # Remove data directory
    if [ -d "$DATA_DIR" ]; then
        sudo rm -rf "$DATA_DIR"
        print_info "Removed data directory from $DATA_DIR"
    fi
    
    print_info "Uninstallation complete!"
}

# Verify uninstallation
verify_uninstall() {
    print_step "Verifying uninstallation..."
    
    if ! command -v $CLI_NAME &> /dev/null; then
        print_info "$CLI_NAME has been successfully removed"
        return 0
    else
        print_warning "Warning: $CLI_NAME is still accessible in PATH"
        return 1
    fi
}

# Main
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  ${RED}$CLI_NAME${BLUE} Uninstallation Script ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
    echo ""
    
    check_installed
    
    # Confirmation
    echo ""
    read -p "Are you sure you want to uninstall $CLI_NAME? (yes/no) " -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_warning "Uninstallation cancelled"
        exit 0
    fi
    
    uninstall
    verify_uninstall
    
    echo ""
    print_info "Uninstallation finished!"
    echo ""
}

main "$@"
