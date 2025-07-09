#!/bin/bash

# rtdog Release Script
# Usage: ./scripts/release.sh [major|minor|patch]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="rtdog"
SCHEME="rtdog"
CONFIGURATION="Release"
ARCHIVE_PATH="./releases"
APP_NAME="rtdog.app"
BUNDLE_ID="tse-coders.rtdog"

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

# Check if we're in the right directory
if [ ! -f "${PROJECT_NAME}.xcodeproj/project.pbxproj" ]; then
    log_error "Project file not found. Please run this script from the project root."
    exit 1
fi

# Check for clean working directory
if [ -n "$(git status --porcelain)" ]; then
    log_error "Working directory is not clean. Please commit or stash your changes."
    exit 1
fi

# Check if we're on main or develop branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "develop" ]; then
    log_warning "You're not on main or develop branch. Current branch: $CURRENT_BRANCH"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get current version
if [ -f "VERSION" ]; then
    CURRENT_VERSION=$(cat VERSION)
else
    log_error "VERSION file not found"
    exit 1
fi

log_info "Current version: $CURRENT_VERSION"

# Determine version bump type
BUMP_TYPE=${1:-patch}

if [ "$BUMP_TYPE" != "major" ] && [ "$BUMP_TYPE" != "minor" ] && [ "$BUMP_TYPE" != "patch" ]; then
    log_error "Invalid bump type. Use: major, minor, or patch"
    exit 1
fi

# Calculate new version
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

case $BUMP_TYPE in
    "major")
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    "minor")
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    "patch")
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
log_info "New version will be: $NEW_VERSION"

# Confirm with user
read -p "Continue with release $NEW_VERSION? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Release cancelled"
    exit 0
fi

# Update VERSION file
echo "$NEW_VERSION" > VERSION
log_success "Updated VERSION file to $NEW_VERSION"

# Update Xcode project version
log_info "Updating Xcode project version..."
xcrun agvtool new-marketing-version "$NEW_VERSION"
xcrun agvtool next-version -all

# Create releases directory
mkdir -p "$ARCHIVE_PATH"

# Build and archive
log_info "Building release archive..."
xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
           -scheme "$SCHEME" \
           -configuration "$CONFIGURATION" \
           -destination 'platform=macOS' \
           archive \
           -archivePath "${ARCHIVE_PATH}/${PROJECT_NAME}-${NEW_VERSION}.xcarchive"

if [ $? -eq 0 ]; then
    log_success "Archive created successfully"
else
    log_error "Archive build failed"
    exit 1
fi

# Export app
log_info "Exporting application..."
mkdir -p "${ARCHIVE_PATH}/v${NEW_VERSION}"

# Copy the app from archive
cp -R "${ARCHIVE_PATH}/${PROJECT_NAME}-${NEW_VERSION}.xcarchive/Products/Applications/${APP_NAME}" \
      "${ARCHIVE_PATH}/v${NEW_VERSION}/"

# Create DMG (optional - requires create-dmg tool)
if command -v create-dmg &> /dev/null; then
    log_info "Creating DMG..."
    create-dmg \
        --volname "${PROJECT_NAME} ${NEW_VERSION}" \
        --window-pos 200 120 \
        --window-size 600 300 \
        --icon-size 100 \
        --icon "${APP_NAME}" 175 120 \
        --hide-extension "${APP_NAME}" \
        --app-drop-link 425 120 \
        "${ARCHIVE_PATH}/v${NEW_VERSION}/${PROJECT_NAME}-${NEW_VERSION}.dmg" \
        "${ARCHIVE_PATH}/v${NEW_VERSION}/"
    
    if [ $? -eq 0 ]; then
        log_success "DMG created successfully"
    fi
else
    log_warning "create-dmg not found. Skipping DMG creation."
    log_info "Install with: brew install create-dmg"
fi

# Create ZIP
log_info "Creating ZIP archive..."
cd "${ARCHIVE_PATH}/v${NEW_VERSION}"
zip -r "${PROJECT_NAME}-${NEW_VERSION}.zip" "${APP_NAME}"
cd - > /dev/null

# Commit changes
log_info "Committing version changes..."
git add VERSION "${PROJECT_NAME}.xcodeproj/project.pbxproj"
git commit -m "chore: bump version to $NEW_VERSION"

# Create git tag
log_info "Creating git tag..."
git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"

log_success "Release $NEW_VERSION completed successfully!"
log_info "Files created:"
log_info "  - Archive: ${ARCHIVE_PATH}/${PROJECT_NAME}-${NEW_VERSION}.xcarchive"
log_info "  - App: ${ARCHIVE_PATH}/v${NEW_VERSION}/${APP_NAME}"
log_info "  - ZIP: ${ARCHIVE_PATH}/v${NEW_VERSION}/${PROJECT_NAME}-${NEW_VERSION}.zip"

if [ -f "${ARCHIVE_PATH}/v${NEW_VERSION}/${PROJECT_NAME}-${NEW_VERSION}.dmg" ]; then
    log_info "  - DMG: ${ARCHIVE_PATH}/v${NEW_VERSION}/${PROJECT_NAME}-${NEW_VERSION}.dmg"
fi

echo
log_info "Next steps:"
log_info "1. Push changes: git push origin $CURRENT_BRANCH"
log_info "2. Push tag: git push origin v$NEW_VERSION"
log_info "3. Update CHANGELOG.md"
log_info "4. Distribute to colleagues"
log_info "5. Create GitHub/GitLab release (if using)" 
