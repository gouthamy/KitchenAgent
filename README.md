# Kitchen Agent - Smart Fridge Management App

A production-quality iOS app for managing kitchen inventory with AI-powered photo recognition, expiry tracking, recipe suggestions, and shopping list management.

## 🎯 Features

### ✅ Implemented Features

1. **Photo-Based Item Detection**
   - Take photos or upload from gallery
   - Automatic item recognition using Vision Framework
   - Estimated quantity detection
   - Smart category assignment

2. **Smart Inventory Management**
   - Track items by storage location (Fridge, Freezer, Pantry)
   - Quantity and unit tracking
   - Purchase and expiry date management
   - Photo storage for each item

3. **Expiry Tracking & Reminders**
   - Visual indicators for items expiring soon
   - Automatic notifications before items expire
   - Configurable daily reminders
   - Expired items tracking

4. **Recipe Suggestions**
   - AI-powered recipe recommendations based on available ingredients
   - Filter recipes by cooking time and difficulty
   - Ingredient matching
   - Favorite recipes

5. **Shopping List Management**
   - Add items quickly
   - Mark items as purchased
   - Recently bought history
   - Clear completed items

6. **User Settings & Preferences**
   - Profile management
   - Notification preferences
   - Unit preferences (g, kg, lb)
   - Family sharing (coming soon)

7. **Beautiful UI/UX**
   - Clean, modern design matching the mockups
   - Smooth animations
   - Intuitive navigation
   - Dark mode support

## 🏗️ Architecture

### Models
- `FridgeItem` - Core inventory item with expiry tracking
- `Recipe` - Recipe with ingredients and instructions
- `ShoppingItem` - Shopping list item
- `UserSettings` - User preferences and settings

### Services
- `ImageRecognitionService` - ML-based food recognition
- `NotificationService` - Local notifications for expiry reminders
- `RecipeService` - Recipe recommendations engine

### Views
- `HomeView` - Dashboard with expiring items and recipe suggestions
- `InventoryView` - Full inventory with filtering
- `AddItemView` - Camera/photo-based item addition
- `ItemDetailView` - Detailed item view with actions
- `ExpiryRemindersView` - Expiry tracking and notifications
- `RecipesView` - Recipe browsing and suggestions
- `ShoppingListView` - Shopping list management
- `SettingsView` - User preferences and settings

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd KitchenAgent
```

2. Open the project:
```bash
open KitchenAgent.xcodeproj
```

3. Add required capabilities in Xcode:
   - Go to Target → Signing & Capabilities
   - Add "Push Notifications"
   - Ensure proper signing is configured

4. Add privacy descriptions:
   - Camera Usage: "We need camera access to scan food items"
   - Photo Library Usage: "We need photo library access to add food items"

5. Build and run (⌘R)

## 📱 Usage

### Adding Items
1. Tap the "+" button on Inventory or Home screen
2. Choose camera or photo gallery
3. Take a photo of your food items
4. The app will automatically detect the item and estimate quantity
5. Review and adjust details
6. Save to inventory

### Managing Expiry
1. View expiring items on Home screen
2. Tap "Expiry Reminders" to see all items
3. Enable daily reminders at your preferred time
4. Get notifications before items expire

### Getting Recipe Suggestions
1. App automatically suggests recipes based on your ingredients
2. Browse all recipes in Recipes tab
3. View recipe details and cooking instructions
4. Mark favorites for quick access

### Shopping List
1. Add items quickly from Shopping tab
2. Mark items as purchased while shopping
3. View recently bought items
4. Clear completed items when done

## 🛠️ Technical Details

### Data Persistence
- Uses SwiftData for local database
- Automatic iCloud sync (optional)
- Image data compression for efficiency

### Image Recognition
- Vision Framework for object detection
- Custom ML model integration ready
- Fallback to default items if detection fails
- Quantity estimation algorithm

### Notifications
- UserNotifications framework
- Local notifications (no server required)
- Scheduled notifications for expiry reminders
- Daily reminder at user-configured time

### Performance
- Lazy loading for large inventories
- Image compression (70% quality)
- Efficient query filtering
- Smooth 60fps animations

## 🔒 Privacy & Security

- All data stored locally on device
- No server communication required
- Photos stored securely in app container
- Optional iCloud sync with end-to-end encryption

## 🎨 Design

Follows Apple's Human Interface Guidelines:
- Native SwiftUI components
- System colors with green accent
- SF Symbols for icons
- Responsive layouts for all iPhone sizes
- Accessibility support

## 📋 Future Enhancements

- [ ] Advanced ML model for better food recognition
- [ ] Barcode scanning for packaged items
- [ ] Nutritional information tracking
- [ ] Family sharing with real-time sync
- [ ] Meal planning calendar
- [ ] Export/import data
- [ ] Apple Watch companion app
- [ ] Widget support
- [ ] Siri shortcuts integration
- [ ] iPad optimization

## 🐛 Known Issues

None at this time. Please report issues on GitHub.

## 📄 License

Copyright © 2026 Goutham Yenuganti. All rights reserved.

## 🤝 Contributing

This is a production app. For contributions, please create a pull request with detailed descriptions.

## 📞 Support

For support, email: goutham.yenuganti@example.com

---

Built with ❤️ using SwiftUI and SwiftData
