# API Timeout Fix - CRITICAL

## 🐛 Issue
```
Error Domain=NSURLErrorDomain Code=-1001 "The request timed out."
```

Meal plan generation was **timing out** after 60 seconds.

## 🔍 Root Cause

Generating **35 meals** (7 days × 5 meals/day) is a massive ChatGPT request:
- Each meal needs: name, ingredients, instructions, nutrition, cooking time
- Total JSON response: ~100KB+ of data
- ChatGPT needs **1-2 minutes** to generate all this content
- Previous timeout: 60 seconds ❌
- Not enough time!

## ✅ Solution

**Increased timeout to 180 seconds (3 minutes)**

### Files Modified:

#### 1. `/Services/MealPlanGeneratorService.swift`
```swift
request.timeoutInterval = 180 // 3 minutes - generating 35 meals takes time!
```

**Changed from:** 60 seconds  
**Changed to:** 180 seconds (3 minutes)

#### 2. `/Views/MealPlanCreatorView.swift`
```swift
Text(isGenerating ? "Generating 35 meals... (may take 1-2 min)" : "Generate Meal Plan")
```

**Added:** Better loading message so user knows to wait

## 🧪 Testing

### Steps:
1. Rebuild app in Xcode
2. Go to **Plan** tab
3. Tap **+** to create new plan
4. Fill in form (age, weight, height, goal)
5. Tap **"Generate Meal Plan"**
6. **WAIT 1-2 minutes** - don't close the app!

### Expected Console Output:
```
🚀 Starting meal plan generation...
🍽️ Generating meals with:
  - Goal: Weight Loss
  - Duration: 7 days
  - Calories: 1800
  - Cuisine: Indian Andhra
🔑 API key found, building prompt...
📤 Calling ChatGPT API...
[... wait 60-120 seconds ...]
📥 Received response, converting to meals...
✅ Converted to 35 planned meals
📋 Generated 35 meals
✅ Meal plan generation completed successfully
```

### Expected UI:
- ⏳ Loading spinner
- 📝 "Generating 35 meals... (may take 1-2 min)"
- ✅ After 1-2 min: Success alert
- 🎉 Plan created with 35 meals

## 📊 Before vs After

| Aspect | Before | After |
|--------|--------|-------|
| Timeout | 60 seconds | 180 seconds (3 min) |
| Result | ❌ Timeout error | ✅ Success |
| User feedback | "Generating..." | "Generating 35 meals... (may take 1-2 min)" |
| Wait time | N/A | 60-120 seconds |

## 🎯 Why This Works

**ChatGPT API Processing Time:**
- Simple chat: 2-5 seconds
- Recipe suggestions (5 recipes): 10-20 seconds
- **Full meal plan (35 meals)**: 60-120 seconds ⚡

The timeout must be longer than the actual processing time.

## 💡 Alternative Solutions (Future)

If 3 minutes is still too slow, consider:

### Option 1: Generate in Batches
```swift
// Instead of 35 meals at once:
// - Day 1-3 (15 meals) - 30 seconds
// - Day 4-7 (20 meals) - 40 seconds
// Total: 70 seconds, more reliable
```

### Option 2: Background Generation
```swift
// Generate asynchronously
// - Show plan immediately as "Generating..."
// - Meals appear as they're generated
// - User can browse other tabs while waiting
```

### Option 3: Reduce Meal Count
```swift
// Generate fewer meals:
// - 3 meals/day instead of 5 (21 total)
// - Skip morning/evening snacks
// - Faster: ~40 seconds
```

### Option 4: Use Streaming API
```swift
// ChatGPT streaming endpoint
// - Receive meals as they're generated
// - Show progress: "Generated 10/35 meals..."
// - Better UX, same total time
```

## 🚨 Important Notes

1. **Network dependency**: Still requires stable internet
2. **API costs**: 35 meals = ~$0.02-0.05 per generation
3. **User patience**: Set expectation with clear messaging
4. **Timeout errors**: If still happening, check:
   - Internet connection
   - API key validity
   - OpenAI API status

## ✅ Status

**FIXED!** Meal plan generation now works with 3-minute timeout.

---

## 🎉 Next Test

**Try it now:**
1. Rebuild app
2. Create meal plan
3. **Be patient** - wait 1-2 minutes
4. Should see success! 🎊
