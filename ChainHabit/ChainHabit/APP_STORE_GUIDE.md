# App Store Submission Guide

## 🎨 App Icon Creation

### Icon Specifications
You need an app icon in the following sizes for iOS:
- **1024×1024px** (App Store)
- 180×180px (iPhone Pro Max, iPhone 15 Pro Max)
- 167×167px (iPad Pro)
- 152×152px (iPad, iPad mini)
- 120×120px (iPhone, iPhone SE)
- 87×87px (iPhone notifications)
- 80×80px (iPad notifications)
- 76×76px (iPad)
- 60×60px (iPhone notifications)
- 58×58px (iPad settings)
- 40×40px (iPhone, iPad spotlight)
- 29×29px (iPhone, iPad settings)
- 20×20px (iPad, iPhone notifications)

### Design Recommendations for HabitTracker

**Option 1: Checkmark with Circle**
- Background: Gradient (e.g., purple to blue)
- Icon: White checkmark in a circle
- Style: Modern, clean, rounded

**Option 2: Flame Icon (Streak Theme)**
- Background: Orange to red gradient
- Icon: Stylized flame with checkmark
- Represents daily streaks

**Option 3: Calendar with Check**
- Background: Solid color (e.g., #3498DB blue)
- Icon: Calendar page with checkmark
- Represents daily tracking

### Tools to Create App Icons

1. **Figma** (Free, Recommended)
   - Create 1024×1024 artboard
   - Design your icon
   - Export as PNG
   - Use online tool to generate all sizes

2. **SF Symbols + Screenshot (Quick)**
   - Use this Swift code to generate a basic icon:

```swift
// Create a temporary view in your app
struct AppIconGenerator: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "9B59B6")!, Color(hex: "3498DB")!],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 500))
                .foregroundStyle(.white)
        }
        .frame(width: 1024, height: 1024)
    }
}
```
   - Take screenshot on Mac at @1x scale
   - Crop to 1024×1024

3. **Online Tools**
   - **AppIconGenerator.com** - Upload 1024×1024, generates all sizes
   - **MakeAppIcon.com** - Similar service
   - **CanvasFlip** - Icon generator

### Adding Icon to Xcode

1. Generate all icon sizes (or use Asset Catalog to auto-generate)
2. In Xcode, select **Assets.xcassets**
3. Click **AppIcon**
4. Drag and drop each size into appropriate slot
5. Or just add 1024×1024 and enable "Single Size" in Xcode 14+

## 📋 Pre-Submission Checklist

### 1. App Information
- [ ] **App Name**: "HabitTracker" or "Daily Habits" or "Habit Streak"
- [ ] **Subtitle**: (30 chars) e.g., "Track Daily Goals"
- [ ] **Description**: Write compelling description (see below)
- [ ] **Keywords**: habit, tracker, daily, routine, goals, streak, productivity
- [ ] **Category**: Primary - Health & Fitness, Secondary - Productivity
- [ ] **Age Rating**: 4+ (no objectionable content)

### 2. Privacy Policy
Since you're collecting no data and using only local storage:

Create a simple privacy policy (required by App Store):

```
Privacy Policy for HabitTracker

Last updated: May 15, 2026

No Data Collection
HabitTracker does not collect, store, or share any personal information. 
All habit data is stored locally on your device using Apple's SwiftData framework.

Data Storage
- All data remains on your device
- No cloud sync or external servers
- No analytics or tracking
- No third-party integrations

Contact
For questions, contact: your.email@example.com
```

Host this on:
- GitHub Pages (free)
- Your own website
- Pastebin or similar service

### 3. Screenshots Required

**iPhone 6.7" (iPhone 15 Pro Max)**
- Need 3-10 screenshots
- Size: 1290 × 2796 pixels

**iPhone 6.5" (iPhone 11 Pro Max, Xs Max)**
- Size: 1242 × 2688 pixels

**iPad Pro 12.9" (6th gen)**
- Size: 2048 × 2732 pixels

**Optimized Screenshot Sequence (Hybrid Focus):**
1. **The Hero:** Main screen showing both Habits (with streaks) and Todo Tasks.
   *Caption: "ALL-IN-ONE PRODUCTIVITY: Habits and Todos in one place."*
2. **Habit Tracking:** Detail view of a habit with the 14-day calendar.
   *Caption: "DON'T BREAK THE CHAIN: Build unstoppable daily streaks."*
3. **Todo List:** The task section with checkmarks.
   *Caption: "NEVER MISS A TASK: Simple, effective todo list management."*
4. **Flexible Scheduling:** The "Every X Days" interval picker.
   *Caption: "FLEXIBLE INTERVALS: Track every 2, 5, or 30 days."*
5. **Privacy & Themes:** A collage of different color themes.
   *Caption: "100% PRIVATE & PERSONAL: Your data, your style, no accounts."*

### 4. App Description Template (Hybrid)

```
Title: ChainHabit: Habit & Todo List

Subtitle: Build Discipline & Streaks

Description:
Stop switching between multiple apps. ChainHabit combines the power of long-term habit building with a simple, effective daily todo list to help you own your day. 

Whether you want to drink more water, hit the gym daily, read more books, or practice mindfulness, ChainHabit keeps you accountable using the power of streaks.

WHY CHAINHABIT WORKS:
The philosophy is simple: once you start a habit, you create a chain. Each day you complete the task, the chain grows longer. Your only job? Don’t break the chain! Seeing your visual progress makes it hard to quit and builds powerful momentum.

✓ HABITS & TODOS IN ONE PLACE
Manage your recurring daily routines alongside your one-time tasks. Whether it's "Mediate for 10 minutes" (Habit) or "Call the plumber" (Todo), ChainHabit handles it all in a beautiful, unified interface.

KEY FEATURES:
• Intuitive Chain Tracker: Easily visualize your daily, weekly, and monthly streaks with a motivating flame indicator.
• Flexible Habit Scheduling: Set habits for specific days, custom intervals (Every X Days), or flexible weekly targets.
• Simple & Intuitive Todo List: Add one-time tasks with ease and check them off with satisfying animations.
• 14-Day Visual History: View your recent consistency at a glance with the built-in calendar view.
• Personal & Private: 10 vibrant color themes, dark mode support, and 100% offline data storage—no accounts or sign-ups required.

Stop procrastinating and start building the best version of yourself. Download ChainHabit today and start your first chain!
```

### 5. App Store Connect Setup

1. **Go to App Store Connect** (appstoreconnect.apple.com)
2. Click **"My Apps"** → **"+"** → **"New App"**
3. Fill in:
   - Platform: iOS
   - Name: Your chosen app name
   - Primary Language: English
   - Bundle ID: (must match Xcode)
   - SKU: (e.g., habittracker-2026)
   - User Access: Full Access

### 6. Pricing & Availability
- Price: **Free**
- Availability: All countries
- Pre-order: No

### 7. In-App Purchases
- None (it's free!)

### 8. App Privacy
In App Store Connect → App Privacy:
- **Data Not Collected**: Select this option
- No tracking
- No data linked to user
- No data used for tracking

## 🚀 Build & Submit Process

### Step 1: Prepare Your App in Xcode

1. **Update Version & Build Number**
   - Select your project in Xcode
   - Go to Target → General
   - Set Version to: `1.0`
   - Set Build to: `1`

2. **Update Bundle Identifier**
   - Use reverse domain: `com.yourname.habittracker`
   - Must be unique

3. **Set Deployment Target**
   - iOS 17.0 (for SwiftData)

4. **Update Display Name**
   - In Info.plist or General settings
   - Set to your final app name

### Step 2: Archive Your App

1. Select **Any iOS Device** (not simulator)
2. Go to **Product** → **Archive**
3. Wait for archive to complete
4. Xcode Organizer opens automatically

### Step 3: Validate & Upload

1. In Organizer, select your archive
2. Click **"Validate App"**
3. Sign in with Apple ID (developer account)
4. Select **"Automatically manage signing"**
5. Click **"Validate"**
6. If successful, click **"Distribute App"**
7. Choose **"App Store Connect"**
8. Click **"Upload"**
9. Wait for upload to complete

### Step 4: Complete App Store Connect

1. Go to appstoreconnect.apple.com
2. Select your app
3. Click version **"1.0"** → **"Prepare for Submission"**
4. Fill in all required fields:
   - Screenshots
   - Description
   - Keywords
   - Support URL (privacy policy URL)
   - Marketing URL (optional)
5. Select your uploaded build
6. Complete questionnaires:
   - Export Compliance: **No** (not using encryption)
   - Content Rights: Check if you own content
   - Advertising Identifier: **No**

### Step 5: Submit for Review

1. Click **"Add for Review"**
2. Click **"Submit to App Review"**
3. Wait for review (usually 24-48 hours)

## 📱 Testing Before Submission

### TestFlight (Optional but Recommended)

1. In App Store Connect → TestFlight
2. Add internal testers (up to 100)
3. Add external testers (need Beta Review)
4. Get feedback before public release

### Things to Test:
- [ ] Create habits
- [ ] Mark complete/incomplete
- [ ] Check streaks work correctly
- [ ] Edit habits
- [ ] Delete habits
- [ ] View detail screens
- [ ] Test on different iPhone sizes
- [ ] Test on iPad (if universal)
- [ ] Test in dark mode
- [ ] Test after app restart (data persists)
- [ ] Test with no habits (empty state)

## 🎯 Post-Launch

### Marketing Ideas
- Share on Twitter/X with #IndieDev
- Post on Reddit r/Apple, r/iOSProgramming
- Share on Product Hunt
- Ask friends to rate & review

### Version Updates
- Monitor crash reports in App Store Connect
- Check reviews for feature requests
- Plan version 1.1 with improvements

### Future Features to Consider
- Widgets for home screen
- iCloud sync
- Reminders/notifications
- Apple Watch app
- Charts and analytics
- Export data
- Habit templates
- Categories/tags

## 📄 Required URLs

You'll need to provide:
1. **Privacy Policy URL** (required)
2. **Support URL** (optional but recommended)
   - Can be same as privacy policy
   - Or create simple page with contact email

Example: `https://yourusername.github.io/habittracker/privacy`

## 💰 Cost Summary

**Free App - No Costs:**
- ✅ Developer Account: Already paid ($99/year)
- ✅ App Submission: Free
- ✅ Hosting Privacy Policy: Free (GitHub Pages)
- ✅ TestFlight: Free
- ✅ Updates: Free forever

**Total Additional Cost: $0**

## 🆘 Common Rejections & How to Avoid

1. **No Privacy Policy** → Add one (see template above)
2. **Crashes** → Test thoroughly
3. **Incomplete Metadata** → Fill all required fields
4. **Wrong Screenshots** → Use exact sizes required
5. **Misleading Description** → Be honest about features
6. **No Content** → Make sure app works without tutorial

## ✅ Final Checklist Before Submit

- [ ] App icon added (all sizes)
- [ ] Version set to 1.0
- [ ] Build number set to 1
- [ ] Bundle ID is unique
- [ ] Privacy policy hosted online
- [ ] Screenshots taken (all required sizes)
- [ ] Description written
- [ ] Keywords chosen
- [ ] App thoroughly tested
- [ ] No crashes or major bugs
- [ ] Dark mode tested
- [ ] Different screen sizes tested
- [ ] Archive validated successfully
- [ ] Build uploaded to App Store Connect
- [ ] All App Store Connect fields filled
- [ ] Export compliance answered (No)

## 🎉 You're Ready!

Once you complete all the above steps, click **"Submit for Review"** and your app will be in Apple's hands. Good luck! 🚀

---

**Questions?** Common issues:
- Archive button grayed out? → Select "Any iOS Device"
- Missing compliance? → Answer "No" to encryption
- Can't find build? → Wait 5-10 minutes after upload
- Validation fails? → Check signing & bundle ID
