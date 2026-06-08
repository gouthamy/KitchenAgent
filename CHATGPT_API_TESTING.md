# ChatGPT API Testing Guide 🤖

## ✅ NEW FEATURE ADDED: API Key Tester!

I've added a built-in API key testing feature to your app!

---

## 🚀 How to Test Your ChatGPT API Key

### **Step 1: Get an OpenAI API Key**

1. **Visit OpenAI Platform:**
   - Go to: https://platform.openai.com/api-keys
   - Sign in (or create account)

2. **Create New API Key:**
   - Click: "Create new secret key"
   - Name it: "Kitchen Agent"
   - Copy the key (starts with `sk-...`)
   - ⚠️ Save it immediately - you can only see it once!

3. **Add Credits (Required!):**
   - Go to: https://platform.openai.com/account/billing
   - Add payment method
   - Add at least $5 credit
   - Without credits, API calls will fail!

---

### **Step 2: Add API Key to App**

1. **Open App:**
   - Launch Kitchen Agent
   - Tap "Settings" tab (bottom right)

2. **Navigate to AI Settings:**
   - Tap "ChatGPT API" (first section at top)
   - Opens "AI Settings" screen

3. **Enter Your API Key:**
   - Tap the "eye" icon to show input field
   - Paste your API key (sk-...)
   - Tap "Save API Key"
   - ✅ "API Key Saved!" message appears

---

### **Step 3: Test the API Key** ⭐ NEW!

1. **Find Test Button:**
   - After saving API key
   - Scroll down to "Test API Key" section
   - You'll see "Test Connection" button

2. **Run Test:**
   - Tap "Test Connection"
   - Shows "Testing..." with spinner
   - Waits 5-10 seconds

3. **See Results:**
   
   **✅ Success:**
   ```
   ✓ API Key is Valid!
   ```
   Your API key works! You're all set!

   **❌ Failure - Invalid Key:**
   ```
   ✗ Test Failed
   Invalid API key - Unauthorized
   ```
   → Check if you copied the full key
   → Make sure it starts with "sk-"

   **❌ Failure - No Credits:**
   ```
   ✗ Test Failed
   Error 429: Rate limit exceeded
   ```
   → Add billing credits at platform.openai.com
   → Need at least $5 minimum

   **❌ Failure - Network:**
   ```
   ✗ Test Failed
   Network connection lost
   ```
   → Check internet connection
   → Try again

---

## 🔍 What the Test Does

The test:
1. **Connects to OpenAI API** (api.openai.com)
2. **Sends your API key** in Authorization header
3. **Requests model list** (simple, free endpoint)
4. **Checks response code:**
   - 200 = ✅ Valid key
   - 401 = ❌ Invalid key
   - 429 = ❌ No credits or rate limited
   - Other = ❌ Network/server error

**Why this works:**
- Uses OpenAI's official `/v1/models` endpoint
- Minimal API cost (fractions of a cent)
- Fast test (5-10 seconds)
- Accurate validation

---

## 💰 API Costs

**Testing:** ~$0.0001 per test (nearly free!)

**Actual Usage (Future Features):**
- Image recognition: ~$0.001 per image
- Recipe suggestions: ~$0.002 per request
- Cooking tips: ~$0.001 per request

**Recommended:** Add $10 credit = ~1000+ API calls

---

## 🎯 Testing Scenarios

### ✅ **VALID API Key Test:**
```
1. Get fresh API key from OpenAI
2. Add $5+ billing credit
3. Paste into app
4. Tap "Test Connection"
5. Result: ✓ API Key is Valid!
```

### ❌ **INVALID API Key Test:**
```
1. Type random text: "sk-test123"
2. Tap "Save API Key"
3. Tap "Test Connection"
4. Result: ✗ Invalid API key - Unauthorized
```

### ❌ **NO CREDITS Test:**
```
1. Use valid API key
2. But account has $0 balance
3. Tap "Test Connection"
4. Result: ✗ Rate limit exceeded
5. Fix: Add credits at platform.openai.com
```

---

## 🔒 Security & Privacy

**Your API key is:**
- ✅ Stored locally on your device only
- ✅ Never sent to our servers
- ✅ Only used for OpenAI API calls
- ✅ Encrypted in device storage
- ✅ Hidden by default (••••••)
- ✅ Can be removed anytime

**We NEVER:**
- ❌ Store your API key on cloud
- ❌ Share your API key with others
- ❌ Use your API key for anything else
- ❌ See your API usage

---

## 📱 Full Testing Workflow

### **Complete Test (Start to Finish):**

```
┌─────────────────────────────────────────┐
│ 1. GET API KEY                          │
├─────────────────────────────────────────┤
│ • Go to platform.openai.com/api-keys    │
│ • Create new key                        │
│ • Copy key (sk-...)                     │
│ • Add $5+ billing credit                │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ 2. ADD TO APP                           │
├─────────────────────────────────────────┤
│ • Settings → ChatGPT API                │
│ • Tap eye icon                          │
│ • Paste key                             │
│ • Tap "Save API Key"                    │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ 3. TEST CONNECTION                      │
├─────────────────────────────────────────┤
│ • Scroll to "Test API Key"              │
│ • Tap "Test Connection"                 │
│ • Wait 5-10 seconds                     │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ 4. CHECK RESULT                         │
├─────────────────────────────────────────┤
│ ✅ Success: "API Key is Valid!"         │
│    → You're ready to use AI features!   │
│                                         │
│ ❌ Failure: See error message           │
│    → Fix issue and test again           │
└─────────────────────────────────────────┘
```

---

## 🛠️ Troubleshooting

### **Problem: "Invalid API key - Unauthorized"**

**Solutions:**
1. Check you copied the ENTIRE key
2. Key should start with `sk-`
3. No spaces at beginning/end
4. Key is from platform.openai.com (not chat.openai.com)
5. Key hasn't been revoked/deleted

**How to Fix:**
- Go back to OpenAI platform
- Create NEW API key
- Copy it carefully
- Paste into app
- Test again

---

### **Problem: "Rate limit exceeded"**

**Solutions:**
1. Add billing credits to OpenAI account:
   - Visit: platform.openai.com/account/billing
   - Add payment method
   - Purchase $5+ credit

2. Wait if you've made too many tests:
   - Wait 60 seconds
   - Try again

**Note:** Free trial credits often expire!

---

### **Problem: "Network connection lost"**

**Solutions:**
1. Check internet connection
2. Switch between WiFi/Cellular
3. Try again in 30 seconds
4. Check if api.openai.com is accessible

---

### **Problem: Test button is disabled/grayed out**

**Cause:** No API key saved

**Solution:**
1. Enter API key first
2. Tap "Save API Key"
3. Test button will become available

---

## 📊 Test Results Interpretation

| Result | Meaning | Action |
|--------|---------|--------|
| ✅ API Key is Valid! | Perfect! Working correctly | No action needed |
| ❌ Invalid API key | Wrong or revoked key | Get new key from OpenAI |
| ❌ Rate limit exceeded | No credits or too many calls | Add credits to account |
| ❌ Network error | Connection problem | Check internet, retry |
| ❌ Timeout | Slow connection | Try again, check WiFi |

---

## 🎬 Visual Guide

### **Settings Screen:**
```
┌─────────────────────────────────────┐
│ ⚙️  Settings                        │
├─────────────────────────────────────┤
│                                     │
│ 🤖 ChatGPT API              >       │  ← Tap here
│ Configure AI features               │
│                                     │
│ 👤 Profile                  >       │
│ Your details                        │
│                                     │
└─────────────────────────────────────┘
```

### **AI Settings Screen:**
```
┌─────────────────────────────────────┐
│ AI Settings                         │
├─────────────────────────────────────┤
│                                     │
│ API Key Configuration               │
│ ┌─────────────────────────────────┐ │
│ │ sk-proj-abc...xyz        👁️    │ │ ← Your key
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │       Save API Key              │ │ ← Tap to save
│ └─────────────────────────────────┘ │
│                                     │
│ ✓ API Key Saved!                    │ ← Confirmation
│                                     │
├─────────────────────────────────────┤
│ Test API Key                        │
│ ┌─────────────────────────────────┐ │
│ │   ▶️  Test Connection           │ │ ← Tap to test
│ └─────────────────────────────────┘ │
│                                     │
│ ✅ API Key is Valid!                │ ← Success!
│                                     │
└─────────────────────────────────────┘
```

---

## 🚀 Quick Test (30 Seconds)

**Fastest way to verify API key:**

```bash
1. Settings → ChatGPT API (5 sec)
2. Paste API key → Save (10 sec)
3. Tap "Test Connection" (5 sec)
4. Wait for result (10 sec)
5. See ✅ or ❌ (instantly)

Total: ~30 seconds!
```

---

## ⚡ Pro Tips

1. **Test Before Using:**
   - Always test API key after adding
   - Ensures it works before trying features

2. **Save API Key Safely:**
   - Store backup copy in password manager
   - Don't share with anyone
   - Don't commit to GitHub

3. **Monitor Credits:**
   - Check balance at platform.openai.com
   - Set up billing alerts
   - $10 = plenty for personal use

4. **Re-test if Issues:**
   - If AI features fail, re-test API key
   - Key might have been revoked
   - Credits might be depleted

5. **Remove When Done:**
   - Tap "Remove API Key" if not using
   - Clears from device storage
   - Can always add again later

---

## 📝 Summary

✅ **Added Features:**
- Built-in API key tester
- "Test Connection" button in AI Settings
- Real-time validation against OpenAI API
- Clear success/failure messages
- Detailed error descriptions

✅ **How to Use:**
1. Settings → ChatGPT API
2. Add your API key
3. Tap "Test Connection"
4. See instant results!

✅ **Benefits:**
- Know immediately if key works
- Catch issues before using features
- Peace of mind
- No guessing!

---

## 🎯 Next Steps

**After successful test:**
1. ✅ API key is configured
2. ✅ AI features are enabled
3. ✅ Ready to use smart features!

**Future AI Features (Coming Soon):**
- 🤖 AI-powered food recognition from photos
- 🍳 Personalized recipe suggestions
- 💡 Smart cooking tips
- 📊 Nutrition insights
- 🛒 Smart shopping lists

---

**Your API key is ready to use!** 🎉
