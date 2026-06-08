# AI Recipe Feature Guide 🤖✨

## 🎉 NEW FEATURES ADDED!

### 1. ChatGPT-Powered Recipe Suggestions
### 2. Recipe Preferences (Indian Andhra by default!)
### 3. Dietary Preferences Support

---

## ✨ FEATURE 1: AI Recipe Suggestions

### **What It Does:**
- Uses **ChatGPT** to generate personalized recipes
- Based on **your available ingredients**
- Matches **your preferred cuisine** (Indian Andhra by default!)
- Respects **dietary preferences** (Vegetarian, Non-Veg, Vegan, etc.)
- Prioritizes **expiring ingredients**

### **How It Works:**

1. **Add Ingredients** to your inventory
2. Go to **Recipes** tab
3. See **"AI Recipe Suggestions"** section at top (purple theme)
4. Tap **"Generate"** button
5. Wait 5-10 seconds
6. Get **5 personalized recipes**!

---

## 🍛 FEATURE 2: Recipe Preferences

### **What It Does:**
- Set your **preferred cuisine type**
- Default: **Indian Andhra** (as requested!)
- Choose dietary preferences
- AI suggestions match your preferences

### **Available Cuisines:**
- **Indian Andhra** ⭐ (Default)
- Indian North
- Indian South
- Chinese
- Italian
- Mexican
- Thai
- Japanese
- Mediterranean
- American
- Middle Eastern
- Continental

### **Dietary Preferences:**
- Vegetarian
- Non-Vegetarian ⭐ (Default)
- Vegan
- Gluten-Free
- Dairy-Free

---

## 🚀 COMPLETE SETUP GUIDE

### **Step 1: Get OpenAI API Key**

1. Visit: https://platform.openai.com/api-keys
2. Sign in or create account
3. Click "Create new secret key"
4. Name it: "Kitchen Agent"
5. Copy key (starts with `sk-...`)
6. **Add $5+ billing credit** (required!)

### **Step 2: Add API Key to App**

1. Open Kitchen Agent
2. Tap **Settings** tab (bottom right)
3. Tap **ChatGPT API Key**
4. Tap eye icon 👁️
5. Paste your API key
6. Tap **"Save API Key"**
7. Tap **"Test Connection"**
8. See ✅ "API Key is Valid!"

### **Step 3: Set Recipe Preferences**

1. In Settings, tap **"Recipe Preferences"**
2. **Preferred Cuisine:** Select "Indian Andhra" (already default!)
3. **Dietary Preferences:** Toggle your choices
   - Vegetarian ✓
   - Non-Vegetarian ✓ (default)
   - Vegan
   - Gluten-Free
   - Dairy-Free
4. Preferences saved automatically!

### **Step 4: Add Ingredients**

1. Go to **Inventory** tab
2. Tap **"+"** button
3. Add items like:
   - Tomato (200g)
   - Onion (150g)
   - Chicken (500g)
   - Rice (1000g)
   - Potatoes (300g)
   - Spices (as needed)

### **Step 5: Generate AI Recipes!**

1. Go to **Recipes** tab
2. See **"AI Recipe Suggestions"** section (purple)
3. Shows your cuisine: **"Indian Andhra"**
4. Shows dietary prefs: **"Non-Vegetarian"**
5. Tap **"Generate"** button
6. Wait while AI generates recipes...
7. Get 5 authentic recipes! 🎉

---

## 📱 USER INTERFACE

### **Recipes Screen:**

```
┌─────────────────────────────────────────┐
│ Recipes                                 │
├─────────────────────────────────────────┤
│ 🔍 Search recipes                       │
│                                         │
│ ┌───────────────────────────────────┐   │
│ │ ✨ AI Recipe Suggestions          │   │ ← NEW!
│ │ Cuisine: Indian Andhra            │   │
│ │ Non-Vegetarian                    │   │
│ │                                   │   │
│ │ [   ✨ Generate   ]  ← Tap this!  │   │
│ │                                   │   │
│ │ ─────────────────────────────────│   │
│ │ ✨ Chicken Biryani                │   │
│ │    30 min • Medium                │   │
│ │    ✓ 8 ingredients available      │   │
│ │                                   │   │
│ │ ✨ Andhra Chicken Curry           │   │
│ │    45 min • Medium                │   │
│ │    ✓ 7 ingredients available      │   │
│ └───────────────────────────────────┘   │
│                                         │
│ Based on your ingredients ─────────────│
│ [Recipe cards...]                       │
└─────────────────────────────────────────┘
```

### **Recipe Preferences:**

```
┌─────────────────────────────────────────┐
│ Recipe Preferences                      │
├─────────────────────────────────────────┤
│ 🍴 Recipe Preferences                   │
│ Customize your recipe suggestions       │
│                                         │
│ Preferred Cuisine                       │
│ ┌───────────────────────────────────┐   │
│ │ Indian Andhra            ▼        │   │ ← Select cuisine
│ └───────────────────────────────────┘   │
│ ChatGPT will suggest recipes from       │
│ your preferred cuisine                  │
│                                         │
│ Dietary Preferences                     │
│ Vegetarian              [  ]            │
│ Non-Vegetarian          [✓]  ← Default │
│ Vegan                   [  ]            │
│ Gluten-Free             [  ]            │
│ Dairy-Free              [  ]            │
│                                         │
│ Current Settings                        │
│ Cuisine: Indian Andhra                  │
│ [Non-Vegetarian]                        │
└─────────────────────────────────────────┘
```

---

## 🎯 HOW AI SUGGESTIONS WORK

### **The AI Considers:**

1. **Your Available Ingredients:**
   - All non-expired items in inventory
   - Example: Tomato, Onion, Chicken, Rice

2. **Your Preferred Cuisine:**
   - "Indian Andhra" (default)
   - Generates authentic regional recipes

3. **Your Dietary Preferences:**
   - Non-Vegetarian (default)
   - Filters out incompatible recipes

4. **Expiring Items (Priority!):**
   - Items expiring in 3 days
   - AI prioritizes using these first

### **Example Prompt Sent to ChatGPT:**

```
You are a helpful cooking assistant. Generate 5 recipe suggestions:

Available Ingredients: Tomato, Onion, Chicken, Rice, Potatoes, Garlic

Preferred Cuisine: Indian Andhra

Dietary Preferences: Non-Vegetarian

Priority: Use these ingredients first (expiring soon): Tomato, Chicken

For each recipe, provide:
1. Recipe name (authentic to Indian Andhra cuisine)
2. Cooking time in minutes
3. Difficulty level (Easy/Medium/Hard)
4. Required ingredients
5. Brief cooking instructions (3-5 steps)
```

### **AI Response Example:**

```json
[
  {
    "name": "Andhra Chicken Curry",
    "cookingTime": 45,
    "difficulty": "Medium",
    "ingredients": ["Chicken", "Tomato", "Onion", "Garlic", "Spices"],
    "instructions": [
      "Marinate chicken with spices for 30 minutes",
      "Heat oil and fry onions until golden",
      "Add tomatoes and cook until soft",
      "Add chicken and cook on medium heat",
      "Garnish with coriander and serve hot"
    ],
    "matchingIngredientsCount": 5
  }
]
```

---

## 🔧 TROUBLESHOOTING

### **Problem: "No recipes found" / Empty AI section**

**Cause:** No API key configured OR no ingredients in inventory

**Solution:**
1. Check Settings → ChatGPT API Key
2. Verify API key is saved (shows ✓)
3. Test connection
4. Add ingredients to inventory

---

### **Problem: "ChatGPT API key not configured"**

**Cause:** API key not set

**Solution:**
1. Settings → ChatGPT API Key
2. Add your OpenAI API key
3. Tap "Test Connection"
4. Should see ✅ "API Key is Valid!"

---

### **Problem: API Error 401 "Invalid API key"**

**Cause:** Wrong or revoked API key

**Solution:**
1. Get fresh API key from platform.openai.com
2. Copy entire key (starts with `sk-...`)
3. Paste into app
4. Test again

---

### **Problem: API Error 429 "Rate limit exceeded"**

**Cause:** No billing credits OR too many requests

**Solution:**
1. Add $5+ credit at platform.openai.com/account/billing
2. Wait 60 seconds
3. Try generating again

---

### **Problem: Recipes don't match my cuisine**

**Cause:** Wrong cuisine preference set

**Solution:**
1. Settings → Recipe Preferences
2. Select "Indian Andhra"
3. Go back to Recipes
4. Generate again

---

### **Problem: Getting vegetarian recipes but I selected Non-Veg**

**Cause:** Dietary preferences not set correctly

**Solution:**
1. Settings → Recipe Preferences
2. Enable "Non-Vegetarian"
3. Disable "Vegetarian" if checked
4. Generate recipes again

---

## 💰 COST ESTIMATION

### **API Costs:**

| Action | Model | Estimated Cost |
|--------|-------|----------------|
| Generate 5 recipes | GPT-4o-mini | ~$0.01 - $0.02 |
| Test API key | GPT-4o-mini | ~$0.0001 |

### **Recommendations:**

- **$5 credit** = ~250-500 recipe generations
- **$10 credit** = ~500-1000 recipe generations
- Very affordable for personal use!

---

## 🎨 VISUAL DESIGN

### **Color Themes:**

- **AI Section:** Purple (`Color.purple`)
  - Purple background
  - Purple icons (sparkles ✨)
  - Purple buttons

- **Regular Recipes:** Green
  - Green background for ingredient-based
  - Gray for all recipes

### **Icons:**

- AI Suggestions: `sparkles` ✨
- Cuisine: `fork.knife.circle.fill` 🍴
- Generate: `wand.and.stars` 🪄
- Loading: ProgressView spinner

---

## 📝 FILES UPDATED

### **New Files:**

1. **RecipePreferencesView.swift**
   - Cuisine selection
   - Dietary preference toggles
   - Current settings display

2. **ChatGPTRecipeService.swift**
   - OpenAI API integration
   - Recipe generation logic
   - Error handling

### **Updated Files:**

1. **UserSettings.swift**
   - Added `preferredCuisine: String` (default "Indian Andhra")
   - Added `dietaryPreferences: [String]` (default ["Non-Vegetarian"])

2. **RecipesView.swift**
   - Added AI Recipe Suggestions section (purple theme)
   - Generate button
   - AI recipe cards
   - Loading states

3. **SettingsView.swift**
   - Added Recipe Preferences link
   - Updated AI section with checkmark indicator
   - Removed placeholder RecipePreferencesView

---

## ✅ FEATURE CHECKLIST

**Recipe Preferences:**
- ✅ Cuisine selection (12 options)
- ✅ Indian Andhra as default
- ✅ Dietary preferences (5 options)
- ✅ Non-Vegetarian as default
- ✅ Visual preference display
- ✅ Auto-save preferences

**AI Recipe Generation:**
- ✅ ChatGPT API integration
- ✅ Generate button
- ✅ Loading state with spinner
- ✅ Error handling
- ✅ Purple theme for AI section
- ✅ 5 recipes per generation
- ✅ Authentic cuisine-specific recipes

**Recipe Display:**
- ✅ AI Recipe Card component
- ✅ Matching ingredients count
- ✅ Cooking time & difficulty
- ✅ Full recipe detail view
- ✅ Step-by-step instructions
- ✅ Ingredients list

**Settings Integration:**
- ✅ Recipe Preferences in Settings
- ✅ ChatGPT API Key section
- ✅ Test Connection feature
- ✅ Checkmark when configured

---

## 🚀 TESTING GUIDE

### **Test 1: Set Preferences**

1. Settings → Recipe Preferences
2. Select "Indian Andhra"
3. Enable "Non-Vegetarian"
4. Check "Current Settings" section
5. ✅ Should show: "Indian Andhra" + "Non-Vegetarian" badge

### **Test 2: Generate AI Recipes**

1. Add ingredients: Chicken, Tomato, Onion, Rice
2. Go to Recipes tab
3. See AI section (purple)
4. Tap "Generate"
5. See loading spinner
6. Wait 5-10 seconds
7. ✅ Should show 5 authentic Andhra recipes

### **Test 3: Recipe Details**

1. After generating recipes
2. Tap any AI recipe card
3. Opens detail view
4. ✅ Should show:
   - Recipe name
   - Sparkles icon
   - Cooking time
   - Difficulty
   - Ingredients list
   - Step-by-step instructions
   - "Generated by ChatGPT" badge

### **Test 4: Error Handling**

1. Remove API key (Settings → ChatGPT API)
2. Go to Recipes tab
3. ✅ AI section should NOT appear
4. Add API key back
5. ✅ AI section reappears

### **Test 5: Different Cuisines**

1. Settings → Recipe Preferences
2. Change to "Italian"
3. Generate recipes
4. ✅ Should get Italian recipes (Pasta, Pizza, etc.)
5. Change back to "Indian Andhra"
6. Generate again
7. ✅ Should get Andhra recipes (Biryani, Curry, etc.)

---

## 📖 USER DOCUMENTATION

### **For End Users:**

**"How do I get AI recipe suggestions?"**

1. Get an OpenAI API key (platform.openai.com)
2. Add $5 credit to your OpenAI account
3. In app: Settings → ChatGPT API Key
4. Paste key and test connection
5. Go to Recipes tab
6. Tap "Generate" button
7. Get personalized recipes!

**"How do I change my cuisine preference?"**

1. Settings → Recipe Preferences
2. Tap "Cuisine Type" dropdown
3. Select your preferred cuisine
4. Auto-saved!
5. Go to Recipes and generate again

**"Why are recipes not matching my diet?"**

Check Settings → Recipe Preferences:
- Enable/disable dietary options
- AI respects ALL enabled preferences
- Generate recipes again after changes

---

## 🎉 SUMMARY

**What's New:**

1. ✨ **ChatGPT-powered recipe suggestions**
   - Generate 5 personalized recipes
   - Based on your ingredients
   - Matches your preferences

2. 🍛 **Recipe Preferences**
   - 12 cuisine options
   - Default: Indian Andhra
   - 5 dietary preferences
   - Default: Non-Vegetarian

3. 📱 **Beautiful UI**
   - Purple theme for AI
   - Generate button
   - Loading states
   - Error handling

4. ⚙️ **Settings Integration**
   - Recipe Preferences view
   - Cuisine selection
   - Dietary toggles
   - Current settings display

---

## 🎯 NEXT STEPS

**Do This Now:**

1. Press ⌘R to build and run
2. Configure ChatGPT API key
3. Set Recipe Preferences to "Indian Andhra"
4. Add some ingredients
5. Generate AI recipes!

**Your users will love:**
- Authentic Andhra recipes
- Personalized suggestions
- Smart use of available ingredients
- Priority on expiring items

---

🎉 **All features implemented and ready to use!** 🚀
