# Shopping List Generator and Cooking Reminders Guide

## Overview

This guide explains the new Shopping List Generator and Cooking Reminders features added to Kitchen Agent.

## Features Implemented

### 1. Shopping List Generator Service
**File:** `/KitchenAgent/Services/ShoppingListGenerator.swift`

#### Key Capabilities:
- **Ingredient Collection**: Collects all ingredients from all meals in a meal plan
- **Smart Aggregation**: Counts how many times each ingredient appears (e.g., 3 meals need onions = 3 onions)
- **Inventory Deduction**: Automatically removes items already in your fridge inventory
- **Categorization**: Groups items by category (Vegetables, Fruits, Meat, Dairy, Grains, Spices, Other)
- **Normalization**: Intelligently handles plurals, measurements, and variations in ingredient names

#### Usage Example:
```swift
// Generate shopping list from meal plan
let shoppingList = ShoppingListGenerator.shared.generateShoppingList(
    from: mealPlan,
    inventory: fridgeItems
)

// Access categorized items
for category in shoppingList.allCategories {
    let items = shoppingList.items(for: category)
    print("\(category.rawValue): \(items.count) items")
}

// Convert to ShoppingItem models for persistence
let shoppingItems = ShoppingListGenerator.shared.convertToShoppingItems(shoppingList)
```

#### Data Structures:

**CategorizedShoppingItem**:
```swift
struct CategorizedShoppingItem {
    let id: UUID
    let name: String
    let quantity: Int
    let category: ItemCategory
    var isPurchased: Bool
}
```

**CategorizedShoppingList**:
```swift
struct CategorizedShoppingList {
    let items: [ItemCategory: [CategorizedShoppingItem]]
    var allCategories: [ItemCategory]
    var totalItemCount: Int
    var isEmpty: Bool
}
```

### 2. Meal Plan Shopping View
**File:** `/KitchenAgent/Views/MealPlan/MealPlanShoppingView.swift`

#### Features:
- **Categorized Display**: Shows items grouped by category with expandable sections
- **Interactive Checkboxes**: Mark items as purchased
- **Add to Shopping List**: Bulk add all items to your persistent shopping list
- **Share Functionality**: Export shopping list as text (SMS, email, notes, etc.)
- **Smart Merging**: When adding to shopping list, updates quantities if item already exists
- **Empty State**: Shows friendly message if all ingredients are already in inventory

#### UI Components:
- Summary header showing total items and categories
- Expandable category sections with item counts
- Individual item rows with checkboxes
- Action buttons for adding to list and sharing
- Loading state with progress indicator
- Error handling with user-friendly alerts

#### Usage:
```swift
// Present as sheet from meal plan view
.sheet(isPresented: $showingShoppingList) {
    MealPlanShoppingView(mealPlan: selectedMealPlan)
}
```

### 3. Enhanced Notification Service
**File:** `/KitchenAgent/Services/NotificationService.swift`

#### New Methods:

**Schedule Single Meal Reminder**:
```swift
try NotificationService.shared.scheduleMealReminder(
    for: meal,
    prepTime: 30  // optional, uses meal's prepTime if nil
)
```

**Schedule Multiple Meal Reminders**:
```swift
NotificationService.shared.scheduleMealReminders(
    for: mealPlan.meals,
    prepTime: 30  // optional
)
```

**Cancel Reminders**:
```swift
// Cancel specific meal reminder
NotificationService.shared.cancelMealReminder(for: mealId)

// Cancel all meal reminders
NotificationService.shared.cancelAllMealReminders()
```

**Check Reminder Status**:
```swift
NotificationService.shared.hasMealReminder(for: mealId) { hasReminder in
    print("Reminder set: \(hasReminder)")
}

// Get all pending meal reminders
NotificationService.shared.getPendingMealReminders { reminders in
    print("Found \(reminders.count) pending reminders")
}
```

#### Notification Content:
- **Title**: "Time to Cook!"
- **Body**: "Time to start cooking [Meal Name]. Takes approximately [X] minutes."
- **Timing**: Sent [prepTime] minutes before the scheduled meal time
- **UserInfo**: Contains mealId, mealName, mealType, and cookingTime for future enhancements

#### Error Handling:
```swift
enum NotificationError: LocalizedError {
    case invalidDate      // Could not calculate notification date
    case pastDate        // Cannot schedule for past date
    case unauthorized    // Notification permission not granted
}
```

### 4. Example Usage View
**File:** `/KitchenAgent/Views/MealPlan/MealPlanDetailView.swift`

This is a complete example showing how to integrate both features:

#### Features Demonstrated:
- Display meal plan details with nutrition targets
- List all meals with their cooking times and scheduled dates
- Generate shopping list button
- Set cooking reminders button with permission handling
- Cancel reminders button
- Visual feedback for reminder status

#### Implementation Pattern:
```swift
// Request notification permission
let authorized = try await NotificationService.shared.requestAuthorization()

// Schedule reminders for all meals
for meal in mealPlan.meals {
    try NotificationService.shared.scheduleMealReminder(for: meal)
    meal.reminderSet = true
}

// Save changes
try modelContext.save()
```

## Production Features

### Error Handling
- All operations wrapped in do-catch blocks
- User-friendly error messages
- Graceful fallbacks for edge cases
- Past date validation for notifications

### Data Safety
- Checks for existing shopping items before adding
- Updates quantities instead of creating duplicates
- Validates dates before scheduling notifications
- Handles missing inventory gracefully

### User Experience
- Loading states during generation
- Empty states when no items needed
- Success alerts for completed actions
- Visual feedback for checkbox interactions
- Smooth animations using Theme.Animation

### Permissions
- Requests notification authorization before scheduling
- Provides clear feedback if permission denied
- Handles authorization status changes

## Styling

All views use the centralized Theme system:
- **Colors**: Theme.Colors.primary, Theme.Colors.success, etc.
- **Spacing**: Theme.Spacing.sm, Theme.Spacing.md, etc.
- **Corner Radius**: Theme.CornerRadius.md, Theme.CornerRadius.lg, etc.
- **Animations**: Theme.Animation.quick, Theme.Animation.normal, etc.
- **Shadows**: Theme.Shadow.light, Theme.Shadow.medium, etc.

## Integration Steps

### 1. Add Files to Xcode
1. Open `KitchenAgent.xcodeproj` in Xcode
2. Add these files to the project:
   - `Services/ShoppingListGenerator.swift`
   - `Views/MealPlan/MealPlanShoppingView.swift`
   - `Views/MealPlan/MealPlanDetailView.swift` (example)
3. Ensure they're added to the KitchenAgent target

### 2. Update Info.plist
Add notification usage description:
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Kitchen Agent sends cooking reminders to help you prepare meals on time.</string>
```

### 3. Use in Your Views
```swift
// In your meal plan list or detail view
NavigationLink(destination: MealPlanDetailView(mealPlan: mealPlan)) {
    // Your meal plan cell
}

// Or present shopping list directly
Button("Shopping List") {
    showingShoppingList = true
}
.sheet(isPresented: $showingShoppingList) {
    MealPlanShoppingView(mealPlan: mealPlan)
}
```

## Testing

### Test Shopping List Generation
1. Create a meal plan with multiple meals
2. Add some ingredients to your inventory
3. Generate shopping list
4. Verify:
   - Items are categorized correctly
   - Quantities are aggregated
   - Inventory items are deducted
   - Empty state shows when all items in inventory

### Test Cooking Reminders
1. Create meals with future dates (at least 1 hour ahead)
2. Set reminders
3. Verify:
   - Permission request appears
   - Success message shows
   - Notification appears in Notification Center
4. Cancel reminders and verify they're removed

### Test Edge Cases
- Empty meal plan → Should show empty state
- All ingredients in inventory → Should show "All Set!" message
- Past meal dates → Should not schedule notifications
- Duplicate shopping items → Should update quantities, not duplicate

## Future Enhancements

Potential improvements:
1. **Recipe Scaling**: Adjust quantities based on serving size
2. **Smart Substitutions**: Suggest alternatives for missing ingredients
3. **Store Locations**: Add aisle/store information to shopping items
4. **Grocery Budget**: Track estimated costs
5. **Shopping History**: Learn from past shopping patterns
6. **Meal Completion**: Mark meals as cooked, auto-update inventory
7. **Interactive Notifications**: Add "Start Timer" action button
8. **Calendar Integration**: Sync meal times with device calendar

## Troubleshooting

### Shopping List Not Generating
- Ensure meal plan has meals with ingredients
- Check that ingredient arrays are not empty
- Verify FridgeItem query is working

### Notifications Not Appearing
- Check Settings > Notifications > Kitchen Agent
- Ensure meal dates are in the future
- Verify prepTime is set correctly
- Check that reminderSet flag is persisted

### Items Not Deducting from Inventory
- Verify ingredient names match (case-insensitive)
- Check normalization logic for unusual ingredient names
- Add custom mappings if needed

## Code Quality

All code follows production standards:
- ✅ Comprehensive error handling
- ✅ Clear documentation and comments
- ✅ Consistent naming conventions
- ✅ SOLID principles
- ✅ Theme-based styling
- ✅ SwiftUI best practices
- ✅ SwiftData integration
- ✅ Preview providers for UI testing
- ✅ Type safety and optionals handling
- ✅ Accessibility support

## Summary

The Shopping List Generator and Cooking Reminders features provide:
- Intelligent shopping list generation with inventory awareness
- Categorized, aggregated ingredient lists
- Timely cooking reminders with customizable prep times
- Seamless integration with existing meal planning
- Production-ready error handling and user experience
- Consistent styling with the app's theme system

These features enhance the meal planning workflow by automating grocery shopping preparation and ensuring users never miss a meal prep time.
