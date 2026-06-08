# Kitchen Agent - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Open Xcode (30 seconds)
```bash
cd /Users/goutham.yenuganti/workspace/kitchenAgent/KitchenAgent
open KitchenAgent.xcodeproj
```

### Step 2: Add Files to Project (2 minutes)

In Xcode:
1. **Right-click** on the blue "KitchenAgent" folder in the left sidebar
2. Select **"Add Files to KitchenAgent..."**
3. Hold **⌘ (Command)** and click to select:
   - `Models` folder
   - `Services` folder  
   - `Views` folder
4. Make sure:
   - ☑️ **"Create groups"** is selected (NOT "Create folder references")
   - ☑️ **"KitchenAgent"** target is checked
   - ☐ **"Copy items if needed"** is UNCHECKED
5. Click **"Add"**

### Step 3: Configure Permissions (1 minute)

1. Click on **"KitchenAgent"** (blue icon) in Project Navigator
2. Select **"KitchenAgent"** target (under "TARGETS")
3. Go to **"Info"** tab
4. Click the **"+"** button twice and add:

   | Key | Value |
   |-----|-------|
   | Privacy - Camera Usage Description | We need camera access to scan and identify food items in your kitchen |
   | Privacy - Photo Library Usage Description | We need photo library access to add food items from your photos |

### Step 4: Enable Notifications (30 seconds)

1. Stay in the **"KitchenAgent"** target
2. Go to **"Signing & Capabilities"** tab
3. Click **"+ Capability"**
4. Search for and add **"Push Notifications"**

### Step 5: Configure Signing (30 seconds)

In the same **"Signing & Capabilities"** tab:
1. Check ☑️ **"Automatically manage signing"**
2. Select your **Team** from the dropdown
3. Xcode will automatically create a bundle identifier

### Step 6: Build & Run (30 seconds)

1. Select a simulator (iPhone 15 or later) or physical device
2. Press **⌘R** (or click the Play button)
3. Wait for build to complete

### Step 7: Test the App (2 minutes)

When the app launches:
1. **Grant Permissions**: Tap "Allow" for Camera and Notifications
2. **Add Your First Item**:
   - Tap "Inventory" tab
   - Tap the "+" button
   - Tap "Camera" or "Gallery"
   - Take/select a photo of food
   - Watch it auto-fill!
   - Tap "Save Item"
3. **Check Home Screen**: See your item and recipe suggestions!

## ✅ Verification

Your app should have:
- ✅ 5 tabs at the bottom (Home, Inventory, Recipes, Shopping, Settings)
- ✅ Green color theme
- ✅ "Hello Priya 👋" greeting (or your name)
- ✅ Ability to add items with camera
- ✅ Recipe suggestions based on ingredients
- ✅ Expiry reminders

## 🐛 Troubleshooting

### "No such module 'SwiftData'"
- Make sure you're using Xcode 15+ and iOS 17+ deployment target

### "Cannot find type 'FridgeItem' in scope"
- Verify all files were added to the target (Step 2)
- Clean build folder: **⌘⇧K**
- Rebuild: **⌘B**

### Camera not working
- Check Info.plist has the camera usage description
- Test on a real device (simulator has limited camera)

### Files not showing in Xcode
- Make sure you selected "Create groups" not "Create folder references"
- Ensure target membership is checked for all files

## 📚 Next Steps

Once the app is running:
- Read **IMPLEMENTATION_GUIDE.md** for full feature documentation
- Read **README.md** for architecture details
- Read **SETUP.md** for advanced configuration

## 🎉 You're Ready!

You now have a fully functional Kitchen Agent app with:
- 📸 Photo-based item detection
- 📅 Expiry tracking and reminders
- 🍳 Smart recipe suggestions
- 🛒 Shopping list management
- ⚙️ Customizable settings

**Enjoy your new kitchen management assistant!**

---

Need help? Check the other documentation files:
- `README.md` - Overview and features
- `SETUP.md` - Detailed setup instructions
- `IMPLEMENTATION_GUIDE.md` - Complete technical guide

Built with ❤️ using SwiftUI
