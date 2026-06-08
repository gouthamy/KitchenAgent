#!/bin/bash

# Kitchen Agent - Automated Xcode Project Setup
# This script helps prepare and open the project in Xcode

set -e  # Exit on error

echo "🚀 Kitchen Agent - Automated Setup"
echo "===================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Xcode is installed
if [ ! -d "/Applications/Xcode.app" ]; then
    echo -e "${RED}❌ Xcode is not installed!${NC}"
    echo ""
    echo "Please install Xcode from the App Store:"
    echo "https://apps.apple.com/us/app/xcode/id497799835"
    exit 1
fi

echo -e "${GREEN}✓${NC} Xcode is installed"

# Set active developer directory
echo ""
echo "📝 Configuring Xcode command line tools..."
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer 2>/dev/null || {
    echo -e "${YELLOW}⚠${NC}  Could not set xcode-select (might need password)"
    echo "   Run manually: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
}

# Verify project file exists
if [ ! -f "KitchenAgent.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ Xcode project file not found!${NC}"
    echo "   Expected: KitchenAgent.xcodeproj/project.pbxproj"
    exit 1
fi

echo -e "${GREEN}✓${NC} Xcode project file found"

# Verify all Swift files exist
echo ""
echo "📋 Verifying files..."

ERRORS=0

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        return 0
    else
        echo -e "${RED}✗${NC} $1/ - MISSING"
        return 1
    fi
}

check_dir "KitchenAgent/Models" || ((ERRORS++))
check_dir "KitchenAgent/Services" || ((ERRORS++))
check_dir "KitchenAgent/Views" || ((ERRORS++))

if [ $ERRORS -ne 0 ]; then
    echo -e "${RED}❌ Some directories are missing!${NC}"
    exit 1
fi

# Count files
MODELS_COUNT=$(ls -1 KitchenAgent/Models/*.swift 2>/dev/null | wc -l | tr -d ' ')
SERVICES_COUNT=$(ls -1 KitchenAgent/Services/*.swift 2>/dev/null | wc -l | tr -d ' ')
VIEWS_COUNT=$(ls -1 KitchenAgent/Views/*.swift 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo -e "${BLUE}📊 Files to add:${NC}"
echo "   Models:   $MODELS_COUNT files"
echo "   Services: $SERVICES_COUNT files"
echo "   Views:    $VIEWS_COUNT files"

# Create a checklist file
cat > XCODE_SETUP_CHECKLIST.txt << EOF
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║            KITCHEN AGENT - XCODE SETUP CHECKLIST                 ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

Follow these steps IN ORDER:

□ STEP 1: Add Files to Project
  ─────────────────────────────
  1. Right-click on "KitchenAgent" folder in Project Navigator
  2. Select "Add Files to KitchenAgent..."
  3. Hold ⌘ (Command) and select these folders:
     □ Models folder (${MODELS_COUNT} files)
     □ Services folder (${SERVICES_COUNT} files)
     □ Views folder (${VIEWS_COUNT} files)
  4. In the dialog, ensure:
     ☑ "Create groups" is selected
     ☑ "KitchenAgent" target is checked
     ☐ "Copy items if needed" is UNCHECKED
  5. Click "Add"

□ STEP 2: Configure Info.plist
  ────────────────────────────
  1. Click "KitchenAgent" (blue icon) in Project Navigator
  2. Select "KitchenAgent" under TARGETS
  3. Go to "Info" tab
  4. Click "+" button twice and add:
     □ Privacy - Camera Usage Description
       Value: We need camera access to scan and identify food items
     □ Privacy - Photo Library Usage Description
       Value: We need photo library access to add food items

□ STEP 3: Enable Push Notifications
  ─────────────────────────────────
  1. Stay in "KitchenAgent" target
  2. Go to "Signing & Capabilities" tab
  3. Click "+ Capability"
  4. Add "Push Notifications"

□ STEP 4: Configure Signing
  ──────────────────────────
  1. In "Signing & Capabilities" tab
  2. Check "Automatically manage signing"
  3. Select your Team
  4. Verify bundle identifier is set

□ STEP 5: Build and Run
  ─────────────────────
  1. Select a simulator (iPhone 15 or later)
  2. Press ⌘R to build and run
  3. Wait for build to complete
  4. Grant permissions when prompted

═══════════════════════════════════════════════════════════════════

Once completed, the app should launch successfully! 🚀

For detailed instructions, see: BUILD_AND_RUN.md
EOF

echo ""
echo -e "${GREEN}✓${NC} Setup checklist created: XCODE_SETUP_CHECKLIST.txt"

# Open the checklist
echo ""
echo "📝 Opening setup checklist..."
open -a TextEdit XCODE_SETUP_CHECKLIST.txt 2>/dev/null || cat XCODE_SETUP_CHECKLIST.txt

# Wait a moment
sleep 2

# Open Xcode
echo ""
echo "🔨 Opening Xcode project..."
open KitchenAgent.xcodeproj

echo ""
echo -e "${GREEN}✅ Xcode is opening!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
echo ""
echo "1. Follow the checklist in XCODE_SETUP_CHECKLIST.txt"
echo "2. Add the Models, Services, and Views folders"
echo "3. Configure Info.plist permissions"
echo "4. Enable Push Notifications"
echo "5. Build and Run (⌘R)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}💡 TIP:${NC} Keep the checklist open and mark off each step!"
echo ""
echo -e "${GREEN}🎉 Ready to build your Kitchen Agent app!${NC}"
echo ""
