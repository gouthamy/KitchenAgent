# Food Emoji Reference 🍅

Quick reference for which food items show which emojis in your app.

## ✅ Items That Will Show Emojis

### 🥬 Vegetables
- **Tomato** → 🍅
- **Carrot** → 🥕  
- **Broccoli** → 🥦
- **Lettuce** → 🥬
- **Spinach** → 🥬
- **Kale** → 🥬
- **Onion** → 🧅
- **Potato** → 🥔
- **Pepper** / **Capsicum** / **Bell Pepper** → 🫑
- **Cucumber** → 🥒
- **Corn** → 🌽
- **Pumpkin** → 🎃
- **Eggplant** → 🍆
- **Garlic** → 🧄
- **Ginger** → 🫚
- **Mushroom** → 🍄
- **Beans** / **Bean** → 🫘
- **Peas** / **Pea** → 🫛
- **Lentils** → 🫘
- **Chickpeas** → 🫘

### 🍎 Fruits
- **Apple** → 🍎
- **Banana** → 🍌
- **Orange** → 🍊
- **Strawberry** → 🍓
- **Grape** → 🍇
- **Watermelon** → 🍉
- **Lemon** → 🍋
- **Lime** → 🍋
- **Mango** → 🥭
- **Pineapple** → 🍍
- **Cherry** → 🍒
- **Peach** → 🍑
- **Pear** → 🍐
- **Blueberry** → 🫐
- **Coconut** → 🥥
- **Kiwi** → 🥝
- **Avocado** → 🥑

### 🥛 Dairy & Eggs
- **Milk** → 🥛
- **Cheese** → 🧀
- **Yogurt** / **Yoghurt** → 🥛
- **Butter** → 🧈
- **Egg** / **Eggs** → 🥚
- **Ice Cream** → 🍦

### 🍗 Meat & Protein
- **Chicken** → 🍗
- **Beef** / **Steak** → 🥩
- **Pork** / **Bacon** → 🥓
- **Fish** → 🐟
- **Shrimp** / **Prawn** → 🦐
- **Tofu** → 🥡

### 🍞 Grains & Bread
- **Bread** → 🍞
- **Rice** → 🍚
- **Pasta** → 🍝
- **Cereal** → 🥣
- **Croissant** → 🥐
- **Bagel** → 🥯

### 🍕 Prepared Foods
- **Pizza** → 🍕
- **Burger** / **Hamburger** → 🍔
- **Sandwich** → 🥪
- **Taco** → 🌮
- **Burrito** → 🌯
- **Sushi** → 🍣
- **Curry** → 🍛
- **Soup** → 🍲
- **Salad** → 🥗

### ☕️ Beverages
- **Juice** → 🧃
- **Coffee** → ☕️
- **Tea** → 🍵
- **Water** → 💧
- **Wine** → 🍷
- **Beer** → 🍺

### 🍰 Desserts
- **Cake** → 🍰
- **Cookie** → 🍪
- **Chocolate** → 🍫
- **Candy** → 🍬
- **Donut** / **Doughnut** → 🍩

### 🍯 Condiments
- **Honey** → 🍯
- **Jam** → 🍯
- **Peanut Butter** → 🥜

---

## ❓ Items Without Specific Emojis

If you add an item not in the list above, it will show:
- **Default**: 🍽️ (fork and knife)
- Still looks good with color-matched background\!

---

## 💡 Pro Tips

### For Best Results:
1. **Use singular or plural** - Both work\! ("Bean" or "Beans")
2. **Case doesn't matter** - "Tomato", "tomato", "TOMATO" all work
3. **Try common names** - "Pepper" instead of "Green Pepper"
4. **Be specific** - "Chicken" shows 🍗, "Meat" shows default 🍽️

### Color Matching:
Items automatically get color-matched backgrounds:
- 🔴 Red: Tomatoes, Strawberries, Cherries
- 🟠 Orange: Carrots, Oranges, Mangoes
- 🟡 Yellow: Lemons, Bananas, Corn
- 🟢 Green: Lettuce, Spinach, Peppers
- 🟤 Brown: Potatoes, Onions, Bread, Beans
- ⚪️ White/Gray: Milk, Eggs, Rice, Tofu

---

## 🎨 Want to Add More?

To add new items:
1. Open `ItemImageProvider.swift`
2. Find the `getEmoji(for:)` function
3. Add your item to the switch statement
4. Add color in `getColor(for:)` function

Example:
```swift
case "broccoli": return "🥦"
```

---

**Now you know which items show emojis\!** 🎉

Try adding: Tomato, Carrot, Apple, Banana, Milk, Eggs, Beans, Chicken, Bread

