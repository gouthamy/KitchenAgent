#\!/bin/bash

echo "🔧 EMOJI FIX & TEST SCRIPT"
echo "=========================="
echo ""

# Step 1: Stop Simulator
echo "1️⃣ Stopping simulator..."
killall Simulator 2>/dev/null
sleep 2
echo "✅ Simulator stopped"
echo ""

# Step 2: Reset Simulator
echo "2️⃣ Resetting all simulators..."
xcrun simctl erase all
sleep 5
echo "✅ Simulators reset"
echo ""

# Step 3: List available simulators
echo "3️⃣ Available simulators:"
xcrun simctl list devices | grep "iPhone"
echo ""

echo "✅ SETUP COMPLETE\!"
echo ""
echo "🚀 NEXT STEPS IN XCODE:"
echo "  1. Select 'iPhone 15 Pro' from device dropdown"
echo "  2. Press ⌘⇧K (Clean Build)"
echo "  3. Press ⌘R (Build & Run)"
echo ""
echo "📱 THEN TEST:"
echo "  - Go to Inventory tab"
echo "  - Tap '+' button"
echo "  - Add item 'Carrot'"
echo "  - Check if you see 🥕 emoji\!"
echo ""

