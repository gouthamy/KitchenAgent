# Setup Instructions

## Required Xcode Configuration

### 1. Add Privacy Permissions

Add the following keys to your `Info.plist`:

#### Camera Permission
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan and identify food items in your kitchen</string>
```

#### Photo Library Permission
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to add food items from your photos</string>
```

**How to add in Xcode:**
1. Select the `KitchenAgent` target
2. Go to the "Info" tab
3. Click the "+" button under "Custom iOS Target Properties"
4. Add `Privacy - Camera Usage Description`
5. Set value: "We need camera access to scan and identify food items in your kitchen"
6. Repeat for `Privacy - Photo Library Usage Description`

### 2. Enable Push Notifications

1. Select the `KitchenAgent` target
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "Push Notifications"
5. Add "Background Modes" (optional, for background notifications)
   - Check "Remote notifications" if implementing server-side notifications later

### 3. Configure Signing

1. Select the `KitchenAgent` target
2. Go to "Signing & Capabilities" tab
3. Ensure "Automatically manage signing" is checked
4. Select your development team
5. Ensure a valid bundle identifier is set (e.g., `com.yourcompany.kitchenagent`)

### 4. Build Settings

Verify the following build settings:

- **iOS Deployment Target**: 17.0 or higher
- **Swift Language Version**: Swift 5
- **Enable SwiftUI**: Yes (default)

### 5. Add Files to Xcode Project

All Swift files have been created in the correct directories. Ensure they're added to the Xcode project:

**Option A: Add via Xcode (Recommended)**
1. Open `KitchenAgent.xcodeproj` in Xcode
2. Right-click on `KitchenAgent` folder in Project Navigator
3. Select "Add Files to KitchenAgent..."
4. Navigate to each folder and add:
   - Models folder (all .swift files)
   - Services folder (all .swift files)
   - Views folder (all .swift files)
5. Ensure "Copy items if needed" is unchecked (files are already in place)
6. Ensure "KitchenAgent" target is checked

**Option B: Auto-detection**
1. Close Xcode
2. Delete `KitchenAgent.xcodeproj/project.pbxproj`
3. Run: `cd path/to/KitchenAgent && xcodebuild -list`
4. This will regenerate the project file (may lose some settings)

**Option C: Manual XML Edit (Advanced)**
Add file references to `project.pbxproj` - see detailed instructions below.

## File Structure Created

```
KitchenAgent/
├── KitchenAgentApp.swift (✅ Updated)
├── ContentView.swift (legacy, can be removed)
├── Item.swift (legacy, can be removed)
├── Models/
│   ├── FridgeItem.swift
│   ├── Recipe.swift
│   ├── ShoppingItem.swift
│   └── UserSettings.swift
├── Services/
│   ├── ImageRecognitionService.swift
│   ├── NotificationService.swift
│   └── RecipeService.swift
└── Views/
    ├── MainTabView.swift
    ├── HomeView.swift
    ├── InventoryView.swift
    ├── AddItemView.swift
    ├── CameraView.swift
    ├── ItemDetailView.swift
    ├── EditItemView.swift
    ├── ExpiryRemindersView.swift
    ├── RecipesView.swift
    ├── RecipeDetailView.swift
    ├── ShoppingListView.swift
    └── SettingsView.swift
```

## Testing Checklist

### Camera & Photos
- [ ] Camera permission prompt appears
- [ ] Can take photo with camera
- [ ] Can select photo from library
- [ ] Image is displayed correctly
- [ ] Image recognition processes the photo

### Notifications
- [ ] Notification permission prompt appears
- [ ] Daily reminder can be scheduled
- [ ] Expiry notifications are scheduled for items
- [ ] Notifications appear at correct time

### Core Features
- [ ] Can add items to inventory
- [ ] Can edit items
- [ ] Can delete items
- [ ] Items are filtered by location
- [ ] Search works correctly
- [ ] Expiry dates are calculated correctly
- [ ] Recipe suggestions appear based on ingredients
- [ ] Shopping list can add/remove items
- [ ] Settings persist correctly

### UI/UX
- [ ] All tabs are accessible
- [ ] Navigation works smoothly
- [ ] Forms validate correctly
- [ ] Empty states show correctly
- [ ] Loading states appear appropriately
- [ ] Animations are smooth

## Troubleshooting

### "Command SwiftCompile failed"
- Check that all files are added to the target
- Verify import statements are correct
- Clean build folder (⌘⇧K) and rebuild

### "Cannot find type X in scope"
- Ensure all Swift files are added to the Xcode project
- Check that files are in the correct target membership
- Verify import statements

### Camera/Photos not working
- Check Info.plist has the correct keys
- Verify permissions in Settings app
- Reset permissions: Settings → General → Reset → Reset Location & Privacy

### Notifications not appearing
- Check notification permissions in Settings
- Verify app is authorized for notifications
- Check notification center settings

### Data not persisting
- Verify SwiftData model configuration
- Check that ModelContainer is properly initialized
- Ensure items are being inserted into the context

## Running the App

1. Select a simulator or physical device (iOS 17.0+)
2. Build and run (⌘R)
3. Grant camera and notification permissions when prompted
4. Test adding an item with camera
5. Verify all features work as expected

## Next Steps

After setup:
1. Test all features thoroughly
2. Add custom food recognition ML model (optional)
3. Customize recipe database
4. Configure iCloud sync (optional)
5. Submit to App Store (requires Apple Developer account)

## Support

For issues during setup:
1. Check error messages carefully
2. Verify all files are properly added
3. Clean and rebuild project
4. Restart Xcode if needed

---

✅ Setup Complete! You now have a fully functional Kitchen Agent app.
