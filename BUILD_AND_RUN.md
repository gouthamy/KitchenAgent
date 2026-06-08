# Build and Run Instructions

## Current Situation

The app code is complete and ready, but the new files need to be added to the Xcode project. Here's how to do it:

## Option 1: Manual Setup in Xcode (Recommended - 3 minutes)

### Step 1: Open Xcode
```bash
# Make sure Xcode is installed and configured
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
open KitchenAgent.xcodeproj
```

### Step 2: Add Files to Project

**In Xcode:**

1. **Right-click** on the blue "KitchenAgent" folder in Project Navigator (left sidebar)
2. Select **"Add Files to KitchenAgent..."**
3. In the file browser, hold **⌘ (Command)** and select these folders:
   - `Models` folder
   - `Services` folder
   - `Views` folder
4. **IMPORTANT Settings in the dialog:**
   - ✅ **"Create groups"** (NOT "Create folder references")
   - ✅ **"KitchenAgent"** target checked
   - ❌ **"Copy items if needed"** UNCHECKED (files are already in place)
5. Click **"Add"**

### Step 3: Configure Info.plist

1. Click on **"KitchenAgent"** (blue project icon at top of navigator)
2. Select **"KitchenAgent"** under TARGETS
3. Go to **"Info"** tab
4. Click the **"+"** button and add these keys:

| Key | Value |
|-----|-------|
| Privacy - Camera Usage Description | We need camera access to scan and identify food items in your kitchen |
| Privacy - Photo Library Usage Description | We need photo library access to add food items from your photos |

### Step 4: Enable Push Notifications

1. Stay in **"KitchenAgent"** target
2. Go to **"Signing & Capabilities"** tab
3. Click **"+ Capability"** button at the top
4. Search for and add **"Push Notifications"**

### Step 5: Configure Signing

1. In **"Signing & Capabilities"** tab
2. Check ✅ **"Automatically manage signing"**
3. Select your **Team** from dropdown
4. Ensure bundle identifier is set (e.g., `com.yourname.kitchenagent`)

### Step 6: Build and Run

1. Select a simulator from the device dropdown (iPhone 15 or later)
   - Or connect a physical iPhone running iOS 17+
2. Press **⌘R** (or click the ▶️ Play button)
3. Wait for build to complete (~30 seconds first time)
4. App will launch in simulator/device

### Step 7: Grant Permissions

When the app launches:
1. Tap **"Allow"** when asked for Camera permission
2. Tap **"Allow"** when asked for Notifications permission
3. You're ready to go!

## Option 2: Automatic Script (If Xcode CLI works)

```bash
# Set Xcode path
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Build the project
xcodebuild -project KitchenAgent.xcodeproj \
  -scheme KitchenAgent \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build

# Run in simulator
open -a Simulator
xcrun simctl boot "iPhone 15" || true
xcrun simctl install booted ./build/Debug-iphonesimulator/KitchenAgent.app
xcrun simctl launch booted com.kitchenagent.app
```

## Option 3: Quick File Reference Script

Run this to generate file references that can be added to Xcode:

```bash
./generate_xcode_references.sh
```

This will create a list of file references you can use.

## Troubleshooting

### "Cannot find type 'FridgeItem' in scope"
**Solution:** Files weren't added to the target
- Select each file in Project Navigator
- Check the "Target Membership" checkbox in File Inspector (right panel)
- Make sure "KitchenAgent" is checked

### "No such module 'SwiftData'"
**Solution:** iOS deployment target too low
- Select project → Build Settings
- Set "iOS Deployment Target" to 17.0 or higher

### Camera not working in Simulator
**Solution:** Use a physical device
- Simulator has limited camera support
- Connect an iPhone and select it as the destination

### Build errors about permissions
**Solution:** Info.plist not configured
- Follow Step 3 above to add privacy keys

### "Developer cannot be verified"
**Solution:** Signing not configured
- Follow Step 5 above to set up signing
- May need an Apple Developer account for device testing

## Verification After Build

Once the app is running, verify these features:

✅ **Home Screen**
- Shows "Hello Priya 👋" greeting
- Displays expiring items section (empty initially)
- Shows recipe suggestions section (empty initially)

✅ **Inventory Tab**
- Empty state shows "No Items" message
- "+" button in top right
- Search bar at top
- Location filter tabs

✅ **Add Item**
- Camera and Gallery buttons work
- Can tap to take/select photo
- Form has all fields (name, quantity, dates, location)
- "Save Item" button works

✅ **Recipes Tab**
- Shows recipe list
- Can tap to view details
- Shows cooking time and difficulty

✅ **Shopping List Tab**
- Can add items via text field
- Items show with checkboxes
- Can mark as purchased

✅ **Settings Tab**
- Shows profile section
- Notification toggle works
- Unit preferences available

## Testing the Full Flow

1. **Add Your First Item:**
   - Go to Inventory tab
   - Tap "+" button
   - Tap "Gallery" (easier for testing)
   - Select any photo
   - App should auto-fill with a vegetable name
   - Adjust quantity if needed
   - Tap "Save Item"

2. **Check Home Screen:**
   - Go back to Home tab
   - Should now see the item in "Expiring Soon" if it expires within 3 days
   - Should see recipe suggestions

3. **Test Expiry Tracking:**
   - Go to Inventory → Expiry Reminders
   - See your items listed
   - Toggle daily reminder
   - Set reminder time

4. **Test Shopping List:**
   - Go to Shopping List tab
   - Type "Milk" and press Enter
   - Item appears with checkbox
   - Tap checkbox to mark as purchased

5. **Test Settings:**
   - Go to Settings tab
   - Tap on profile to edit
   - Change notification time
   - Change unit preference

## Success Indicators

✅ App launches without crashes
✅ All 5 tabs are visible and tappable
✅ Can navigate between screens
✅ Camera/Gallery picker opens
✅ Can add items to inventory
✅ Items persist after closing app
✅ Notifications are scheduled (check Settings app)

## Next Steps After Successful Build

1. **Customize:**
   - Change "Priya" to your name in UserSettings.swift
   - Add more recipes in RecipeService.swift
   - Customize colors/theme

2. **Test Thoroughly:**
   - Add multiple items
   - Test with different storage locations
   - Test expiry date calculations
   - Verify notifications (wait for scheduled time)

3. **Deploy:**
   - Archive for TestFlight
   - Submit to App Store
   - Share with friends/family

## Need Help?

- **Project not building?** Clean build folder (⌘⇧K) and rebuild
- **Files not showing?** Make sure you selected "Create groups" not "Create folder references"
- **Simulator issues?** Try restarting simulator
- **Xcode issues?** Try restarting Xcode

---

**Ready to build!** Follow Option 1 above - it's the most reliable method and takes just 3 minutes! 🚀
