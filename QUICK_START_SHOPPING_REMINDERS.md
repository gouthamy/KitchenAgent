# Quick Start: Shopping List & Cooking Reminders

## 🚀 5-Minute Integration Guide

### Step 1: Add Files to Xcode (2 minutes)

1. Open `KitchenAgent.xcodeproj` in Xcode
2. In Project Navigator, right-click on "KitchenAgent" folder
3. Select "Add Files to KitchenAgent..."
4. Navigate to and select these files:
   - `Services/ShoppingListGenerator.swift`
   - `Services/ShoppingListGeneratorTests.swift`
   - `Views/MealPlan/MealPlanShoppingView.swift`
   - `Views/MealPlan/MealPlanDetailView.swift`
5. **Important settings:**
   - ⚠️ **UNCHECK** "Copy items if needed"
   - ✅ **SELECT** "Create groups"
   - ✅ **CHECK** "KitchenAgent" target
6. Click "Add"

### Step 2: Update Info.plist (30 seconds)

Add notification permission text:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Kitchen Agent sends cooking reminders to help you prepare meals on time.</string>
```

**How to add:**
1. Open `Info.plist` in Xcode
2. Click the + button
3. Type: `NSUserNotificationsUsageDescription`
4. Set value to the string above

### Step 3: Build Project (30 seconds)

```bash
# Clean build folder
⌘ + Shift + K

# Build
⌘ + B
```

### Step 4: Test Shopping List (1 minute)

Add to any view with a meal plan:

```swift
import SwiftUI

struct YourMealPlanView: View {
    let mealPlan: MealPlan
    @State private var showingShoppingList = false
    
    var body: some View {
        Button("Generate Shopping List") {
            showingShoppingList = true
        }
        .sheet(isPresented: $showingShoppingList) {
            MealPlanShoppingView(mealPlan: mealPlan)
        }
    }
}
```

### Step 5: Test Cooking Reminders (1 minute)

```swift
import SwiftUI

struct YourMealView: View {
    let meal: PlannedMeal
    
    var body: some View {
        Button("Set Reminder") {
            Task {
                do {
                    // Request permission
                    let authorized = try await NotificationService.shared.requestAuthorization()
                    
                    guard authorized else {
                        print("Permission denied")
                        return
                    }
                    
                    // Schedule reminder
                    try NotificationService.shared.scheduleMealReminder(for: meal)
                    print("Reminder set!")
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}
```

## ✅ Verify It Works

### Test Shopping List Generation

1. Create or open a meal plan with meals
2. Tap "Generate Shopping List" button
3. You should see:
   - Categorized ingredient list
   - Items grouped by category (Vegetables, Fruits, etc.)
   - Quantity aggregated (e.g., "Onion (2)" if 2 meals need onions)
   - Items already in inventory are excluded

### Test Cooking Reminders

1. Create a meal with a future date (at least 1 hour ahead)
2. Tap "Set Reminder" button
3. Accept notification permission if prompted
4. Check Notification Center - you should see the scheduled notification
5. Wait for the notification to appear at the scheduled time

**Quick Test (1 minute from now):**
```swift
// Create test meal for 2 minutes from now
let testMeal = PlannedMeal(
    date: Date().addingTimeInterval(120), // 2 minutes
    mealType: .breakfast,
    recipeName: "Test Meal",
    recipeInstructions: "Test",
    ingredients: ["test"],
    cookingTime: 10,
    prepTime: 1 // 1 minute prep = notification in 1 minute
)

// Schedule reminder
try NotificationService.shared.scheduleMealReminder(for: testMeal)

// Wait 1 minute - notification should appear!
```

## 📱 Using the Features

### Generate Shopping List

```swift
// From a meal plan view
Button("Shopping List") {
    showingShoppingList = true
}
.sheet(isPresented: $showingShoppingList) {
    MealPlanShoppingView(mealPlan: mealPlan)
}
```

**User can:**
- View categorized ingredients
- Expand/collapse categories
- Check off purchased items
- Add all to shopping list app
- Share via Messages, Mail, etc.

### Schedule Cooking Reminders

```swift
// Schedule for single meal
try NotificationService.shared.scheduleMealReminder(for: meal)

// Schedule for all meals in plan
NotificationService.shared.scheduleMealReminders(for: mealPlan.meals)

// Cancel reminder
NotificationService.shared.cancelMealReminder(for: meal.id)

// Cancel all meal reminders
NotificationService.shared.cancelAllMealReminders()
```

**User receives:**
- Notification [prepTime] minutes before meal
- Title: "Time to Cook!"
- Body: "Time to start cooking [Meal Name]. Takes approximately [X] minutes."

## 🎯 Complete Integration Example

See `MealPlanDetailView.swift` for a full working example that includes:
- Meal plan display
- Shopping list generation button
- Set/cancel reminders buttons
- Permission handling
- Error handling
- Success feedback

**Use it as a template:**
```swift
import SwiftUI

struct MyMealPlanScreen: View {
    let mealPlan: MealPlan
    @State private var showingShoppingList = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Your meal plan UI here
            
            // Add shopping list button
            Button(action: { showingShoppingList = true }) {
                HStack {
                    Image(systemName: "cart.fill")
                    Text("Generate Shopping List")
                }
                .primaryButtonStyle()
            }
            
            // Add reminders button
            Button(action: scheduleReminders) {
                HStack {
                    Image(systemName: "bell.fill")
                    Text("Set Cooking Reminders")
                }
                .primaryButtonStyle()
            }
        }
        .sheet(isPresented: $showingShoppingList) {
            MealPlanShoppingView(mealPlan: mealPlan)
        }
    }
    
    func scheduleReminders() {
        Task {
            let authorized = try await NotificationService.shared.requestAuthorization()
            guard authorized else { return }
            
            NotificationService.shared.scheduleMealReminders(for: mealPlan.meals)
        }
    }
}
```

## 🐛 Troubleshooting

### Shopping List is Empty
**Problem:** All items showing as "already in inventory"  
**Solution:** This is correct behavior! It means you have all ingredients needed.

### Shopping List Not Generating
**Problem:** Nothing happens when tapping button  
**Solution:** 
- Ensure meal plan has meals with ingredients
- Check console for errors
- Verify SwiftData query is working

### Notifications Not Appearing
**Problem:** Reminders not showing up  
**Solution:**
1. Check Settings > Notifications > Kitchen Agent
2. Ensure "Allow Notifications" is ON
3. Ensure meal date is in the future
4. Check notification was scheduled: Settings > Notifications > Scheduled
5. For testing, set meal 2-3 minutes in future with 1 minute prep time

### Permission Always Asking
**Problem:** Permission prompt appears every time  
**Solution:** Grant permission permanently in Settings > Notifications > Kitchen Agent

### Build Errors
**Problem:** Xcode shows compile errors  
**Solution:**
1. Clean Build Folder (⌘⇧K)
2. Delete Derived Data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Close and reopen Xcode
4. Build again (⌘B)

### Files Not Found
**Problem:** Xcode can't find ShoppingListGenerator  
**Solution:**
1. Files must be added through Xcode, not just copied to folder
2. Check files are in Project Navigator
3. Check files have KitchenAgent target checked (File Inspector)
4. Try removing and re-adding files

## 📚 More Information

- **Full Documentation:** `SHOPPING_LIST_AND_REMINDERS_GUIDE.md`
- **Usage Examples:** `ShoppingListGeneratorTests.swift`
- **Integration Example:** `MealPlanDetailView.swift`
- **Features Summary:** `NEW_FEATURES_SUMMARY.md`

## 🎉 Success Checklist

- [ ] Files added to Xcode project
- [ ] Info.plist updated with notification permission
- [ ] Project builds without errors
- [ ] Shopping list generates and shows categorized items
- [ ] Notification permission prompt works
- [ ] Reminders schedule successfully
- [ ] Notifications appear at correct time
- [ ] Can cancel reminders
- [ ] Can share shopping list
- [ ] Can add items to shopping list app

## 🚀 Next Steps

1. Integrate into your meal planning flow
2. Test with real meal plans
3. Customize UI to match your app design
4. Add analytics tracking (optional)
5. Consider adding features like:
   - Recipe scaling
   - Store locations
   - Price tracking
   - Shopping history

---

**Need Help?**
- Check the detailed guide: `SHOPPING_LIST_AND_REMINDERS_GUIDE.md`
- Review working example: `MealPlanDetailView.swift`
- Run test examples: `ShoppingListGeneratorTests.swift`

**Enjoy your new features! 🎊**
