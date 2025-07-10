#!/bin/bash

# rtdog - Office Day Tracker
# One-Click Installation Script for macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/ccdaniele/rtdog/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
REPO_OWNER="ccdaniele"
REPO_NAME="rtdog"
APP_NAME="rtdog"
BUNDLE_ID="tse-coders.rtdog"
INSTALL_DIR="/Applications"
TEMP_DIR="/tmp/rtdog-install"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${BOLD}$1${NC}"
}

# Check system requirements
check_requirements() {
    log_step "🔍 Checking system requirements..."
    
    # Check macOS version
    local macos_version=$(sw_vers -productVersion)
    local major_version=$(echo $macos_version | cut -d. -f1)
    local minor_version=$(echo $macos_version | cut -d. -f2)
    
    if [[ $major_version -lt 15 ]] || [[ $major_version -eq 15 && $minor_version -lt 5 ]]; then
        log_error "macOS 15.5 or later required. Current version: $macos_version"
        exit 1
    fi
    
    log_success "macOS version: $macos_version ✓"
    
    # Check if running on Apple Silicon or Intel
    local arch=$(uname -m)
    if [[ "$arch" == "arm64" ]]; then
        log_info "Detected Apple Silicon Mac"
    elif [[ "$arch" == "x86_64" ]]; then
        log_info "Detected Intel Mac"
    else
        log_warning "Unknown architecture: $arch"
    fi
}

# Get latest release info
get_latest_release() {
    log_step "🔄 Fetching latest release information..."
    
    # Use GitHub API to get latest release
    local api_url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    
    if command -v curl &> /dev/null; then
        local release_info=$(curl -s "$api_url")
        LATEST_VERSION=$(echo "$release_info" | grep '"tag_name"' | cut -d'"' -f4)
        DOWNLOAD_URL=$(echo "$release_info" | grep '"browser_download_url"' | grep '\.zip"' | grep -v '\.sha256"' | head -1 | cut -d'"' -f4)
    else
        log_error "curl not found. Please install curl or download manually."
        exit 1
    fi
    
    if [[ -z "$LATEST_VERSION" ]]; then
        log_error "Could not fetch latest release information"
        exit 1
    fi
    
    log_success "Latest version: $LATEST_VERSION"
    log_info "Download URL: $DOWNLOAD_URL"
}

# Download and verify
download_app() {
    log_step "📥 Downloading rtdog $LATEST_VERSION..."
    
    # Create temp directory
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Download ZIP file
    local zip_file="${APP_NAME}-${LATEST_VERSION}.zip"
    
    if [[ -n "$DOWNLOAD_URL" ]]; then
        log_info "Downloading from GitHub releases..."
        curl -L -o "$zip_file" "$DOWNLOAD_URL"
    else
        # Fallback to direct download
        local fallback_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${LATEST_VERSION}/${zip_file}"
        log_info "Downloading from: $fallback_url"
        curl -L -o "$zip_file" "$fallback_url"
    fi
    
    # Verify download
    if [[ ! -f "$zip_file" ]]; then
        log_error "Download failed"
        exit 1
    fi
    
    local file_size=$(stat -f%z "$zip_file" 2>/dev/null || echo "unknown")
    log_success "Downloaded successfully (${file_size} bytes)"
    
    # Extract ZIP
    log_info "Extracting application..."
    unzip -q "$zip_file"
    
    if [[ ! -d "${APP_NAME}.app" ]]; then
        log_error "Application not found in downloaded package"
        exit 1
    fi
    
    log_success "Extraction completed"
}

# Install application
install_app() {
    log_step "🚀 Installing rtdog..."
    
    # Remove existing installation
    if [[ -d "${INSTALL_DIR}/${APP_NAME}.app" ]]; then
        log_info "Removing existing installation..."
        rm -rf "${INSTALL_DIR}/${APP_NAME}.app"
    fi
    
    # Copy new version
    log_info "Copying application to ${INSTALL_DIR}..."
    cp -R "${APP_NAME}.app" "$INSTALL_DIR/"
    
    # Set proper permissions
    chmod -R 755 "${INSTALL_DIR}/${APP_NAME}.app"
    
    log_success "Application installed successfully"
}

# Handle Gatekeeper
handle_gatekeeper() {
    log_step "🔐 Configuring security settings..."
    
    local app_path="${INSTALL_DIR}/${APP_NAME}.app"
    
    # Remove quarantine attribute
    log_info "Removing quarantine attribute..."
    xattr -dr com.apple.quarantine "$app_path" 2>/dev/null || true
    
    # Check code signature
    log_info "Checking code signature..."
    if codesign -v "$app_path" 2>/dev/null; then
        log_success "Code signature valid"
    else
        log_warning "Code signature not found - this is normal for unsigned applications"
        log_info "You may need to allow the app in System Preferences > Security & Privacy"
    fi
}

# Launch application
launch_app() {
    log_step "🎉 Launch rtdog..."
    
    local app_path="${INSTALL_DIR}/${APP_NAME}.app"
    
    # Ask user if they want to launch now
    echo -e "\n${BOLD}Installation completed successfully!${NC}"
    echo
    echo "rtdog has been installed to: $app_path"
    echo
    
    # Check if running in non-interactive mode (piped)
    if [[ -t 0 ]]; then
        read -p "Would you like to launch rtdog now? (y/N) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Launching rtdog..."
            open "$app_path"
            log_success "rtdog launched! 🎉"
        else
            log_info "You can launch rtdog from your Applications folder or Spotlight"
        fi
    else
        log_info "Auto-launching rtdog in non-interactive mode..."
        open "$app_path"
        log_success "rtdog launched! 🎉"
    fi
}

# Cleanup
cleanup() {
    log_step "🧹 Cleaning up..."
    cd /
    rm -rf "$TEMP_DIR"
    log_success "Cleanup completed"
}

# Track installation (optional analytics)
track_installation() {
    # Optional: Log installation to GitHub (requires GitHub CLI)
    if command -v gh &> /dev/null; then
        log_info "Logging installation analytics..."
        local install_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        local system_info="macOS $(sw_vers -productVersion) ($(uname -m))"
        
        # This would require a GitHub token, so we'll skip for now
        # gh api repos/$REPO_OWNER/$REPO_NAME/dispatches -f event_type=install -f client_payload="{\"version\":\"$LATEST_VERSION\",\"date\":\"$install_date\",\"system\":\"$system_info\"}" 2>/dev/null || true
    fi
}

# Main installation flow
main() {
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                                                      ║"
    echo "║                                        rtdog - Office Day Tracker                                                   ║"
    echo "║                                        One-Click Installation                                                        ║"
    echo "║                                                                                                                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BOLD}Welcome to rtdog installer!${NC}"
    echo "This script will install rtdog - Office Day Tracker on your Mac."
    echo
    echo "Features:"
    echo "• 📅 Track your hybrid work schedule"
    echo "• 📊 Monitor office day compliance"
    echo "• 🔔 Smart notification reminders"
    echo "• 📄 Generate detailed reports"
    echo "• 🔒 All data stored locally on your Mac"
    echo
    
    # Confirm installation
    # Check if running in non-interactive mode (piped)
    if [[ -t 0 ]]; then
        read -p "Continue with installation? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled by user"
            exit 0
        fi
    else
        log_info "Running in non-interactive mode, proceeding with installation..."
    fi
    
    # Run installation steps
    check_requirements
    get_latest_release
    download_app
    install_app
    handle_gatekeeper
    track_installation
    launch_app
    cleanup
    
    echo
    echo -e "${BOLD}${GREEN}🎉 Installation Complete!${NC}"
    echo
    echo "rtdog is now ready to help you track your office days!"
    echo
    echo "Next steps:"
    echo "1. Launch rtdog from Applications or Spotlight"
    echo "2. Grant notification permissions if prompted"
    echo "3. Start logging your work locations"
    echo "4. Customize settings as needed"
    echo
    echo "Need help? Check the README at: https://github.com/${REPO_OWNER}/${REPO_NAME}"
    echo
    echo "Happy tracking! 🏢🏠"
}

# Error handling
trap 'log_error "Installation failed. Please check the error above or install manually."; cleanup; exit 1' ERR

# Run main function
main "$@" 
