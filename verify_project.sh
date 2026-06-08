#!/bin/bash

# Kitchen Agent - Project Verification Script
# Verifies that all files are in place and ready for build

echo "🔍 Kitchen Agent - Project Verification"
echo "========================================"
echo ""

PROJECT_DIR="KitchenAgent"
MODELS_DIR="$PROJECT_DIR/Models"
SERVICES_DIR="$PROJECT_DIR/Services"
VIEWS_DIR="$PROJECT_DIR/Views"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 - MISSING"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        return 0
    else
        echo -e "${RED}✗${NC} $1/ - MISSING"
        return 1
    fi
}

ERRORS=0

# Check directory structure
echo "📁 Checking directory structure..."
check_dir "$MODELS_DIR" || ((ERRORS++))
check_dir "$SERVICES_DIR" || ((ERRORS++))
check_dir "$VIEWS_DIR" || ((ERRORS++))
echo ""

# Check Models
echo "📦 Checking Models..."
check_file "$MODELS_DIR/FridgeItem.swift" || ((ERRORS++))
check_file "$MODELS_DIR/Recipe.swift" || ((ERRORS++))
check_file "$MODELS_DIR/ShoppingItem.swift" || ((ERRORS++))
check_file "$MODELS_DIR/UserSettings.swift" || ((ERRORS++))
echo ""

# Check Services
echo "⚙️  Checking Services..."
check_file "$SERVICES_DIR/ImageRecognitionService.swift" || ((ERRORS++))
check_file "$SERVICES_DIR/NotificationService.swift" || ((ERRORS++))
check_file "$SERVICES_DIR/RecipeService.swift" || ((ERRORS++))
echo ""

# Check Views
echo "🎨 Checking Views..."
check_file "$VIEWS_DIR/MainTabView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/HomeView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/InventoryView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/AddItemView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/CameraView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/ItemDetailView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/EditItemView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/ExpiryRemindersView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/RecipesView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/RecipeDetailView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/ShoppingListView.swift" || ((ERRORS++))
check_file "$VIEWS_DIR/SettingsView.swift" || ((ERRORS++))
echo ""

# Check main files
echo "🏠 Checking main files..."
check_file "$PROJECT_DIR/KitchenAgentApp.swift" || ((ERRORS++))
echo ""

# Check documentation
echo "📚 Checking documentation..."
check_file "README.md" || ((ERRORS++))
check_file "SETUP.md" || ((ERRORS++))
check_file "IMPLEMENTATION_GUIDE.md" || ((ERRORS++))
check_file "Info-Keys-Template.plist" || ((ERRORS++))
echo ""

# Count files
MODELS_COUNT=$(ls -1 $MODELS_DIR/*.swift 2>/dev/null | wc -l | tr -d ' ')
SERVICES_COUNT=$(ls -1 $SERVICES_DIR/*.swift 2>/dev/null | wc -l | tr -d ' ')
VIEWS_COUNT=$(ls -1 $VIEWS_DIR/*.swift 2>/dev/null | wc -l | tr -d ' ')

echo "📊 Summary:"
echo "=========="
echo "Models:      $MODELS_COUNT/4 files"
echo "Services:    $SERVICES_COUNT/3 files"
echo "Views:       $VIEWS_COUNT/12 files"
echo ""

# Final status
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All files present!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Open KitchenAgent.xcodeproj in Xcode"
    echo "2. Add the Models, Services, and Views folders to the project"
    echo "3. Configure Info.plist with camera and photo permissions"
    echo "4. Enable Push Notifications capability"
    echo "5. Build and run (⌘R)"
    echo ""
    echo "See SETUP.md for detailed instructions."
else
    echo -e "${RED}❌ Found $ERRORS error(s)!${NC}"
    echo ""
    echo "Please check the missing files above."
    exit 1
fi

# Check for potential issues
echo ""
echo "🔍 Additional checks..."

# Check if old files exist that should be removed
if [ -f "$PROJECT_DIR/ContentView.swift" ]; then
    echo -e "${YELLOW}⚠${NC}  Found legacy ContentView.swift (can be removed after migration)"
fi

if [ -f "$PROJECT_DIR/Item.swift" ]; then
    echo -e "${YELLOW}⚠${NC}  Found legacy Item.swift (can be removed after migration)"
fi

# Check for Xcode project
if [ -f "KitchenAgent.xcodeproj/project.pbxproj" ]; then
    echo -e "${GREEN}✓${NC} Xcode project file exists"
else
    echo -e "${RED}✗${NC} Xcode project file not found!"
    ((ERRORS++))
fi

echo ""
echo "🎉 Verification complete!"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "Your Kitchen Agent project is ready to build! 🚀"
    exit 0
else
    exit 1
fi
