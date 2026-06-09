# Meal Planning & Diet Feature - Implementation Plan 📋

## 🎯 YOUR REQUIREMENTS

Based on your request, you want:

1. **Diet Plans** - Weight loss, maintenance, muscle gain
2. **Meal Scheduling** - What to eat, when to eat
3. **Shopping Lists** - What to purchase for the plan
4. **Meal Prep Schedule** - When to prepare each meal
5. **Cooking Reminders** - Notifications to start cooking
6. **Calendar View** - Visual schedule of all meals
7. **Nutrition Tracking** - Protein, fat, sugar, carbs in recipes
8. **Recipe Database** - Currently hardcoded, need to expand or use AI

---

## ✅ WHAT I'VE ALREADY CREATED

### **1. Data Models Created:**

**NutritionInfo.swift** - Tracks:
- Calories
- Protein (g)
- Carbs (g)
- Fat (g)
- Fiber (g)
- Sugar (g)

**MealPlan.swift** - Includes:
- Diet goals (Weight Loss, Maintenance, Muscle Gain)
- Daily calorie/macro targets
- Start/end dates
- List of planned meals

**PlannedMeal.swift** - Includes:
- Date & meal type (Breakfast, Lunch, Dinner, Snacks)
- Recipe details
- Ingredients
- Nutrition info
- Cooking time
- Prep time (when to start cooking)
- Reminder settings
- Completion status

**Updated Recipe.swift**:
- Added nutrition field

---

## 📱 FEATURES TO IMPLEMENT

### **PHASE 1: Core Meal Planning** ⭐ (Highest Priority)

#### **1.1 Meal Plan Creator View**
- Select diet goal (Weight Loss, Maintenance, Muscle Gain)
- Set duration (1 week, 2 weeks, 1 month)
- Input personal details:
  - Age, weight, height, gender
  - Activity level
  - Target weight
- Calculate daily calorie & macro targets
- Generate meal plan

#### **1.2 Calendar View**
- Show 7-day week view
- Each day shows:
  - Breakfast time & recipe
  - Morning snack
  - Lunch time & recipe
  - Evening snack
  - Dinner time & recipe
- Tap meal to see details
- Swipe between weeks

#### **1.3 Recipe Detail with Nutrition**
- Show existing recipe info
- Add nutrition panel:
  ```
  Nutrition Facts (per serving)
  ━━━━━━━━━━━━━━━━━━━━━━
  Calories: 450 kcal
  Protein: 25g  (22%)
  Carbs: 45g    (40%)
  Fat: 15g      (38%)
  Fiber: 8g
  Sugar: 5g
  ```
- Visual progress bars for macros

---

### **PHASE 2: Smart Shopping Lists** 🛒

#### **2.1 Shopping List from Meal Plan**
- Button: "Generate Shopping List"
- Analyzes all meals for the week
- Groups ingredients by category:
  - Vegetables
  - Fruits
  - Dairy
  - Meat
  - Grains
  - Spices
- Shows quantities needed
- Deducts items already in inventory!
- "Buy Only Missing Items"

#### **2.2 Shopping Schedule**
- Suggests when to shop:
  - "Shop Sunday for the week"
  - "Buy fresh vegetables Wednesday"
- Perishable items reminder

---

### **PHASE 3: Meal Prep Schedule** 👨‍🍳

#### **3.1 Prep Timeline View**
- Shows cooking schedule for each day
- Example:
  ```
  Monday, July 8
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  7:30 AM - Start Breakfast
    → Oatmeal with fruits (15 min)
  
  12:30 PM - Start Lunch
    → Chicken Salad (20 min)
  
  7:00 PM - Start Dinner
    → Grilled Fish with Veggies (30 min)
  ```

#### **3.2 Cooking Reminders**
- Set reminders for:
  - When to start cooking
  - When meal is ready
- Notifications:
  ```
  🔔 Time to cook dinner!
  Start making Grilled Fish now
  (Takes 30 minutes)
  ```

---

### **PHASE 4: Progress Tracking** 📊

#### **4.1 Daily Nutrition Dashboard**
- Shows today's totals vs targets
- Progress rings for:
  - Calories (1800 / 2000)
  - Protein (80g / 100g)
  - Carbs (200g / 250g)
  - Fat (50g / 70g)
- Mark meals as eaten
- Visual feedback

#### **4.2 Weekly Summary**
- Chart showing daily calorie intake
- Macro distribution pie chart
- Meals completed vs missed
- Weight progress (if tracking)

---

### **PHASE 5: AI Integration** 🤖

#### **5.1 AI-Generated Meal Plans**
- Use ChatGPT to generate:
  - Complete 7-day meal plan
  - Based on diet goal
  - Respects cuisine preference
  - Includes nutrition info
  - All recipes with instructions

#### **5.2 Dynamic Recipe Database**
- Option 1: Hardcode more recipes (quick)
- Option 2: Use ChatGPT to generate recipes on demand
- Option 3: Allow users to add custom recipes
- Recommended: Mix of all three!

---

## 🎯 IMPLEMENTATION PRIORITY

### **START WITH (This Week):**

1. ✅ **Nutrition Display in Recipes** (Easy)
   - Update RecipeDetailView to show nutrition
   - Add nutrition to hardcoded recipes

2. ✅ **Basic Meal Plan Creator** (Medium)
   - Simple form to create meal plan
   - Select goal, duration
   - Calculate targets

3. ✅ **Calendar View** (Medium)
   - 7-day horizontal scroll
   - Show meals per day
   - Tap to see details

4. ✅ **Shopping List Generator** (Easy)
   - Button to generate from plan
   - List all ingredients
   - Deduct inventory items

### **ADD LATER (Next Week):**

5. ⏳ **Cooking Reminders** (Easy)
   - Notifications before meal time
   - "Start cooking now"

6. ⏳ **Progress Tracking** (Medium)
   - Daily nutrition dashboard
   - Mark meals as eaten
   - Visual progress

7. ⏳ **AI Meal Plan Generation** (Medium)
   - ChatGPT integration
   - Generate complete plans
   - Includes nutrition

---

## 💡 QUICK WINS (What We Can Do Now!)

### **Option A: Enhanced Recipe Display** (30 minutes)

Add nutrition panel to recipe detail view:
```swift
// Nutrition Section
VStack(alignment: .leading, spacing: 12) {
    Text("Nutrition Facts")
        .font(.headline)
    
    NutritionRow(label: "Calories", value: "\(calories) kcal")
    NutritionRow(label: "Protein", value: "\(protein)g", percentage: 22)
    NutritionRow(label: "Carbs", value: "\(carbs)g", percentage: 40)
    NutritionRow(label: "Fat", value: "\(fat)g", percentage: 38)
    NutritionRow(label: "Sugar", value: "\(sugar)g")
}
```

### **Option B: Add More Recipes** (1 hour)

Update RecipeService.swift with:
- 20+ weight-loss friendly recipes
- Each with nutrition info
- Categorize by meal type
- Include calorie counts

### **Option C: Basic Meal Planner** (2 hours)

Create simple meal planner:
1. Select goal (Weight Loss)
2. Choose 7 recipes for the week
3. Auto-generate shopping list
4. Show in calendar view

---

## 🤔 QUESTIONS FOR YOU

### **Q1: Recipe Database**

Which approach do you prefer?

**A.** Hardcode 50-100 recipes with nutrition
  - ✅ Fast, works offline
  - ❌ Limited variety

**B.** Use ChatGPT to generate recipes on demand
  - ✅ Unlimited variety
  - ❌ Requires API key & internet

**C.** Mix: Hardcoded + ChatGPT + User custom
  - ✅ Best of both
  - ❌ More complex

**Recommendation:** Start with A (hardcode 20-30 popular recipes), add B later.

### **Q2: Meal Plan Customization**

How much control do users need?

**Simple:** System generates entire plan (1-click)
**Medium:** Choose recipes from suggestions
**Advanced:** Full control - pick each meal

**Recommendation:** Start Simple, add options later.

### **Q3: Calorie Calculation**

**Manual:** User enters their targets
**Automatic:** Calculate based on age/weight/goal

**Recommendation:** Automatic with manual override.

---

## 🚀 WHAT I'LL BUILD FIRST (Your Approval?)

### **MVP: Weight Loss Meal Planner**

**Features:**
1. ✅ Create Weight Loss Plan
   - Duration: 1 week
   - Auto-calculate calorie target
   - Daily: Breakfast, Lunch, Dinner + 2 snacks

2. ✅ Calendar View
   - 7-day horizontal scroll
   - Each day shows 5 meals
   - Tap meal to see recipe

3. ✅ Recipe Details with Nutrition
   - Calories, protein, carbs, fat, sugar
   - Visual progress bars
   - Cooking instructions

4. ✅ Shopping List Generator
   - "Generate Shopping List" button
   - Groups by category
   - Deducts inventory items
   - One-tap add to Shopping tab

5. ✅ Cooking Reminders
   - Set reminder for each meal
   - Notification: "Start cooking Lunch now"
   - 30 min before meal time

**Timeline:** 1-2 days to build MVP

**After MVP:**
- Add more recipes (with nutrition)
- Progress tracking dashboard
- AI-generated meal plans
- Weekly summary charts

---

## 📊 EXAMPLE: Weight Loss Plan

### **User Profile:**
- Goal: Lose weight
- Current: 80kg, Target: 75kg
- Duration: 4 weeks
- Activity: Moderate

### **Daily Targets:**
- Calories: 1800 kcal (20% deficit)
- Protein: 100g (22%)
- Carbs: 200g (45%)
- Fat: 60g (33%)

### **Sample Day:**

```
Monday, July 8, 2024
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

8:00 AM - BREAKFAST
🥣 Oatmeal with Berries
   350 kcal | P: 12g | C: 55g | F: 8g
   [Start cooking at 7:45 AM] 🔔

11:00 AM - MORNING SNACK
🍎 Apple with Almond Butter
   150 kcal | P: 4g | C: 20g | F: 7g

1:00 PM - LUNCH
🥗 Grilled Chicken Salad
   450 kcal | P: 35g | C: 30g | F: 15g
   [Start cooking at 12:30 PM] 🔔

5:00 PM - EVENING SNACK
🥤 Protein Smoothie
   200 kcal | P: 20g | C: 25g | F: 3g

8:00 PM - DINNER
🐟 Baked Fish with Veggies
   600 kcal | P: 40g | C: 45g | F: 18g
   [Start cooking at 7:30 PM] 🔔

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DAILY TOTALS:
Calories: 1750 / 1800 ✅
Protein: 111g / 100g ✅
Carbs: 175g / 200g ✅
Fat: 51g / 60g ✅
```

---

## 🎨 UI MOCKUP

### **New "Meal Plan" Tab**

```
┌─────────────────────────────────────────┐
│ 🍽️ Meal Plan                            │
├─────────────────────────────────────────┤
│                                         │
│ ┌───────────────────────────────────┐   │
│ │ 💪 Weight Loss Plan               │   │
│ │ Goal: Lose 5kg in 4 weeks         │   │
│ │                                   │   │
│ │ Today's Progress:                 │   │
│ │ Calories: 850 / 1800  ⚪⚪⚪⚪⚫    │   │
│ │ Protein: 45g / 100g   ⚪⚪⚫⚫⚫    │   │
│ └───────────────────────────────────┘   │
│                                         │
│ This Week                               │
│ ┌─────┬─────┬─────┬─────┬─────┬─────┐  │
│ │ Mon │ Tue │ Wed │ Thu │ Fri │ Sat │  │
│ │ ✅  │ ✅  │ 👉 │     │     │     │  │
│ └─────┴─────┴─────┴─────┴─────┴─────┘  │
│                                         │
│ Today's Meals (Wednesday)               │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━│
│ 🌅 8:00 AM - Breakfast                 │
│    Oatmeal (350 kcal)            [✓]   │
│                                         │
│ ☕ 11:00 AM - Snack                    │
│    Apple (150 kcal)              [✓]   │
│                                         │
│ ☀️ 1:00 PM - Lunch                     │
│    Chicken Salad (450 kcal)      [ ]   │
│    🔔 Reminder set for 12:30 PM        │
│                                         │
│ 🍵 5:00 PM - Snack                     │
│    Smoothie (200 kcal)           [ ]   │
│                                         │
│ 🌙 8:00 PM - Dinner                    │
│    Baked Fish (600 kcal)         [ ]   │
│    🔔 Reminder set for 7:30 PM         │
│                                         │
│ ┌───────────────────────────────────┐   │
│ │ [📝 Generate Shopping List]      │   │
│ └───────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

---

## ❓ NEXT STEPS

**Please tell me:**

1. **Do you want me to build the MVP now?** (1-2 days)
   - Meal Plan Creator
   - Calendar View
   - Nutrition Display
   - Shopping List Generator
   - Cooking Reminders

2. **Recipe Database Preference?**
   - Hardcode 20-30 recipes, OR
   - Use ChatGPT to generate

3. **Any specific dietary requirements?**
   - Vegetarian options?
   - Low carb?
   - Indian Andhra focus?

4. **Feature Priority?**
   - Most important: Calendar view? Shopping list? Reminders?

---

**Once you confirm, I'll start building! This is a significant feature that will make your app much more valuable.** 🚀
