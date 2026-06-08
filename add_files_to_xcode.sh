#!/bin/bash

# Kitchen Agent - Add Files to Xcode Project Script
# This script helps add new Swift files to the Xcode project

echo "🚀 Kitchen Agent - Adding files to Xcode project..."
echo ""

PROJECT_FILE="KitchenAgent.xcodeproj/project.pbxproj"
PROJECT_DIR="KitchenAgent"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Error: Could not find $PROJECT_FILE"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "📋 Files to add:"
echo ""

# List all new Swift files
echo "Models:"
ls -1 $PROJECT_DIR/Models/*.swift 2>/dev/null

echo ""
echo "Services:"
ls -1 $PROJECT_DIR/Services/*.swift 2>/dev/null

echo ""
echo "Views:"
ls -1 $PROJECT_DIR/Views/*.swift 2>/dev/null

echo ""
echo "⚠️  IMPORTANT: Files must be added through Xcode for proper configuration"
echo ""
echo "📝 Steps to add files in Xcode:"
echo ""
echo "1. Open KitchenAgent.xcodeproj in Xcode"
echo "2. Right-click on 'KitchenAgent' folder in Project Navigator"
echo "3. Select 'Add Files to KitchenAgent...'"
echo "4. Select the Models, Services, and Views folders"
echo "5. Make sure:"
echo "   - 'Copy items if needed' is UNCHECKED"
echo "   - 'Create groups' is selected"
echo "   - 'KitchenAgent' target is CHECKED"
echo "6. Click 'Add'"
echo ""
echo "✅ After adding files:"
echo "   - Clean Build Folder (⌘⇧K)"
echo "   - Build (⌘B)"
echo "   - Run (⌘R)"
echo ""

# Check if files exist
MODELS_COUNT=$(ls -1 $PROJECT_DIR/Models/*.swift 2>/dev/null | wc -l)
SERVICES_COUNT=$(ls -1 $PROJECT_DIR/Services/*.swift 2>/dev/null | wc -l)
VIEWS_COUNT=$(ls -1 $PROJECT_DIR/Views/*.swift 2>/dev/null | wc -l)

echo "📊 Summary:"
echo "   Models: $MODELS_COUNT files"
echo "   Services: $SERVICES_COUNT files"
echo "   Views: $VIEWS_COUNT files"
echo ""
echo "✨ All files are ready to be added to your Xcode project!"
