#!/bin/bash

# Upload Release to GitHub
# This script uploads the current release to GitHub for distribution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if GitHub CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed. Please install it first:"
        echo "  brew install gh"
        exit 1
    fi
    
    # Check if user is authenticated
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated. Please run:"
        echo "  gh auth login"
        exit 1
    fi
    
    log_success "GitHub CLI is installed and authenticated"
}

# Get current version
get_current_version() {
    if [ -f "VERSION" ]; then
        CURRENT_VERSION=$(cat VERSION)
        log_info "Current version: $CURRENT_VERSION"
    else
        log_error "VERSION file not found"
        exit 1
    fi
}

# Check if release files exist
check_release_files() {
    local release_dir="releases/v${CURRENT_VERSION}"
    local zip_file="${release_dir}/rtdog-${CURRENT_VERSION}.zip"
    
    if [ ! -d "$release_dir" ]; then
        log_error "Release directory not found: $release_dir"
        log_info "Please run the release script first: ./scripts/release.sh"
        exit 1
    fi
    
    if [ ! -f "$zip_file" ]; then
        log_error "ZIP file not found: $zip_file"
        log_info "Please run the release script first: ./scripts/release.sh"
        exit 1
    fi
    
    log_success "Release files found in $release_dir"
}

# Generate checksums
generate_checksums() {
    local release_dir="releases/v${CURRENT_VERSION}"
    local zip_file="${release_dir}/rtdog-${CURRENT_VERSION}.zip"
    local checksum_file="${release_dir}/rtdog-${CURRENT_VERSION}.zip.sha256"
    
    log_info "Generating checksums..."
    
    cd "$release_dir"
    shasum -a 256 "rtdog-${CURRENT_VERSION}.zip" > "rtdog-${CURRENT_VERSION}.zip.sha256"
    cd ../..
    
    log_success "Checksums generated: $checksum_file"
}

# Create release notes
create_release_notes() {
    local notes_file="release_notes_temp.md"
    local version_section_found=false
    
    log_info "Generating release notes from CHANGELOG.md..."
    
    # Extract release notes from CHANGELOG.md
    if [ -f "CHANGELOG.md" ]; then
        awk -v version="$CURRENT_VERSION" '
        /^## \[.*\]/ {
            if (found) exit
            if (match($0, "\\[" version "\\]")) {
                found = 1
                next
            }
        }
        found && /^## \[.*\]/ { exit }
        found && !/^## \[.*\]/ { print }
        ' CHANGELOG.md > "$notes_file"
        
        # Check if we found version-specific notes
        if [ -s "$notes_file" ]; then
            version_section_found=true
            log_success "Found version-specific release notes"
        else
            log_warning "No version-specific release notes found in CHANGELOG.md"
        fi
    else
        log_warning "CHANGELOG.md not found"
    fi
    
    # If no specific notes found, create generic ones
    if [ "$version_section_found" = false ]; then
        cat > "$notes_file" << EOF
## What's Changed
* Bug fixes and improvements
* See CHANGELOG.md for full details
EOF
    fi
    
    # Add installation instructions
    cat >> "$notes_file" << EOF

## 🚀 Quick Install
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/ccdaniele/rtdog/main/install.sh | bash
\`\`\`

Or download the ZIP file below and extract to Applications folder.

## 📊 Features
- 📅 Visual calendar with work location tracking
- 📊 Monthly office day quota monitoring
- 🔔 Interactive notification reminders
- 📄 Generate PDF reports with statistics
- 🔒 Complete privacy - all data stored locally

## 🔐 Security Note
This app is not signed with an Apple Developer certificate. When you first run it, macOS may show a security warning. Right-click the app and select "Open", then click "Open" in the dialog. The one-click installer handles this automatically.

## 📄 More Information
- **Landing Page**: https://ccdaniele.github.io/rtdog/install.html
- **Repository**: https://github.com/ccdaniele/rtdog
- **Issues**: https://github.com/ccdaniele/rtdog/issues
EOF
    
    log_success "Release notes created: $notes_file"
}

# Upload release to GitHub
upload_release() {
    local release_dir="releases/v${CURRENT_VERSION}"
    local zip_file="${release_dir}/rtdog-${CURRENT_VERSION}.zip"
    local checksum_file="${release_dir}/rtdog-${CURRENT_VERSION}.zip.sha256"
    local notes_file="release_notes_temp.md"
    local tag_name="v${CURRENT_VERSION}"
    
    log_info "Uploading release to GitHub..."
    
    # Check if release already exists
    if gh release view "$tag_name" &> /dev/null; then
        log_warning "Release $tag_name already exists on GitHub"
        read -p "Do you want to delete it and create a new one? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deleting existing release..."
            gh release delete "$tag_name" --yes
        else
            log_info "Keeping existing release, updating assets..."
            # Upload/update assets
            gh release upload "$tag_name" "$zip_file" "$checksum_file" --clobber
            log_success "Assets updated for release $tag_name"
            return
        fi
    fi
    
    # Create new release
    log_info "Creating GitHub release $tag_name..."
    gh release create "$tag_name" \
        "$zip_file" \
        "$checksum_file" \
        --title "rtdog $tag_name" \
        --notes-file "$notes_file" \
        --latest
    
    log_success "Release $tag_name created successfully!"
}

# Generate download statistics
show_download_info() {
    local tag_name="v${CURRENT_VERSION}"
    
    echo
    echo "🎉 Release uploaded successfully!"
    echo
    echo "📦 GitHub Release: https://github.com/ccdaniele/rtdog/releases/tag/$tag_name"
    echo "📄 Landing Page: https://ccdaniele.github.io/rtdog/install.html"
    echo
    echo "🚀 Installation Commands:"
    echo "  One-click: curl -fsSL https://raw.githubusercontent.com/ccdaniele/rtdog/main/install.sh | bash"
    echo "  Manual: Download ZIP from releases page"
    echo
    echo "📊 Distribution Ready:"
    echo "  ✓ GitHub Release created"
    echo "  ✓ Installation script available"
    echo "  ✓ Checksums generated"
    echo "  ✓ Professional landing page"
    echo
    echo "📢 Share with your team:"
    echo "  Email: Include one-click install command"
    echo "  Slack: Share landing page URL"
    echo "  Teams: Use installation instructions from DISTRIBUTION.md"
}

# Cleanup
cleanup() {
    if [ -f "release_notes_temp.md" ]; then
        rm -f "release_notes_temp.md"
    fi
}

# Main function
main() {
    echo "🚀 rtdog GitHub Release Uploader"
    echo "================================="
    echo
    
    # Run all checks and operations
    check_gh_cli
    get_current_version
    check_release_files
    generate_checksums
    create_release_notes
    upload_release
    show_download_info
    cleanup
    
    echo
    echo "🎯 Next Steps:"
    echo "1. Enable GitHub Pages in repository settings"
    echo "2. Share installation instructions with your team"
    echo "3. Monitor download statistics in GitHub Insights"
    echo "4. Collect user feedback via GitHub Issues"
    echo
    echo "Happy distributing! 🐕"
}

# Error handling
trap 'log_error "Upload failed. Please check the error above."; cleanup; exit 1' ERR

# Run main function
main "$@" 
