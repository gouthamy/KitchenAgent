#\!/bin/bash

echo "🧹 Cleaning Kitchen Agent project..."
echo ""

# Clean derived data
echo "1. Cleaning Derived Data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/KitchenAgent-* 2>/dev/null
echo "   ✅ Done"

# Clean build folder
echo ""
echo "2. Project is ready for rebuild"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔨 NEXT STEPS IN XCODE:"
echo ""
echo "1. Quit Xcode (⌘Q) if running"
echo "2. Reopen KitchenAgent.xcodeproj"
echo "3. Clean Build: ⌘⇧K"
echo "4. Build & Run: ⌘R"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Cleanup complete\! Go rebuild in Xcode\!"
