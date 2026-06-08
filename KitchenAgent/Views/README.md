# 🥗 KitchenAgent

**KitchenAgent** is an iOS app that helps you manage your kitchen inventory, reduce food waste, and decide what to cook based on what you already have. Snap a photo of an item, track expiry dates, get reminders before food goes bad, and discover recipes built around your fridge contents.

---

## ✨ Features

### 📦 Inventory Management
- Add food items with name, quantity, unit, category, and storage location (Fridge, Freezer, Pantry).
- Browse your inventory in a clean card-based grid.
- Search items by name and filter by storage location.
- View detailed item pages with quantity, location, purchase/expiry dates, and notes.
- Edit or delete items at any time.

### 📸 Smart Item Capture
- Add items by taking a photo with the camera or choosing one from your photo library.
- On-device image recognition suggests the item's name, category, and an estimated quantity.
- Automatic expiry-date estimation based on the recognized food type.

### ⏰ Expiry Tracking & Reminders
- Visual indicators for items expiring soon or already expired.
- "Days left" countdown on each item.
- Local notifications scheduled one day before an item expires.
- Optional daily reminder to check your fridge.

### 🍳 Recipe Suggestions
- Get recipe ideas based on the ingredients you currently have.
- See how many of a recipe's ingredients you already own.
- Browse all recipes, search by name, and mark favorites.
- Each recipe shows cooking time and difficulty (Easy / Medium / Hard).

### 🛒 Shopping List
- Quickly add items you need to buy.
- Check items off as you purchase them.
- "To Buy" and "Recently Bought" sections.
- Clear completed items in one tap.

### 🏠 Home Dashboard
- Personalized greeting.
- "Expiring Soon" carousel of at-risk items.
- "You can cook" suggestions based on items about to expire.

### ⚙️ Settings
- User profile (name, email, profile photo).
- Notification preferences and daily reminder time.
- Preferred measurement unit.
- Family-sharing toggle.

---

## 🚀 Features That Would Be Nice to Have (Roadmap)

- **iCloud / CloudKit sync** so inventory and shopping lists stay in sync across devices.
- **Real family sharing** built on a shared CloudKit container.
- **Barcode scanning** to auto-fill product details.
- **Improved AI recognition** with quantity/weight estimation and multi-item detection in a single photo.
- **Nutrition & calorie info** per item and per recipe.
- **Meal planning / weekly menu** generation.
- **Auto-add to shopping list** when an item runs low or is consumed.
- **Waste analytics** — track how much food expired vs. was used.
- **Recipe import** from URLs and a larger online recipe database.
- **Home Screen widgets** for "expiring soon" and the shopping list.
- **Siri Shortcuts / App Intents** ("Add milk to my fridge").
- **Localization** for multiple languages and unit systems.
- **Dark mode polish** and accessibility (Dynamic Type, VoiceOver) refinements.

---

## 🛠 Tech Stack

- **Swift** & **SwiftUI** for the UI.
- **SwiftData** (`@Model`, `@Query`, `ModelContainer`) for persistence.
- **PhotosUI** for photo-library selection.
- **UserNotifications** for expiry reminders.
- On-device image recognition for food identification.

---

## 📋 Requirements

- **Xcode 15 or later**
- **iOS 17 or later** (SwiftData requires iOS 17+)
- A Mac running a compatible version of macOS for Xcode

---

## ▶️ How to Run

1. **Open the project**
   - Open `KitchenAgent.xcodeproj` (or `.xcworkspace` if present) in Xcode.

2. **Select a run destination**
   - In the toolbar, choose an **iOS Simulator** (e.g., *iPhone 15*) **or** a connected iPhone.
   - ⚠️ Do **not** select "My Mac" — this app uses iOS-only APIs (camera, PhotosUI, UIKit imaging) and will not build for macOS.

3. **(Optional) Set your signing team**
   - For running on a physical device: select the project → **Signing & Capabilities** → choose your Apple ID / Team.

4. **Build and run**
   - Press **⌘R** (or click the ▶️ Run button).

5. **Grant permissions when prompted**
   - **Notifications** — to receive expiry reminders.
   - **Camera / Photos** — to capture or pick item images.

### 🧪 Running Tests
- Press **⌘U** to run the test suite (includes UI launch tests).

---

## 🧰 Troubleshooting

- **`Invalid redeclaration of 'Recipe'` / weird `modelContainer ... missing import SwiftData` errors**
  These usually mean a duplicate type (e.g., a stray `Recipe 2.swift`) exists in the project. Delete the duplicate file, then **Product ▸ Clean Build Folder** (⇧⌘K) and rebuild.

- **App won't build for macOS**
  Make sure the run destination is an iOS Simulator or device, not "My Mac".

- **Notifications not appearing**
  Confirm notification permission was granted in **Settings ▸ KitchenAgent ▸ Notifications**.

---

## 📁 Project Structure (high level)

