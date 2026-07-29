# ChainHabit – iOS App Store Deployment Checklist

A step-by-step record of everything needed to publish and improve ChainHabit on the App Store. Checked items are done; unchecked items are still needed.

---

## Phase 1 – App Icon

- [x] Generate 1024×1024 icon image
- [x] Create all required icon sizes (via appicon.co or similar)
- [x] Add all icon sizes to Assets.xcassets in Xcode

---

## Phase 2 – Xcode Project Setup

- [x] Set unique Bundle ID: `com.krishnapradhan.HabitTrackerApp`
- [x] Set Version to 1.0, Build to 1
- [x] Set Display Name
- [x] Configure signing (Automatically manage signing)
- [x] Set Deployment Target: iOS 17.0

---

## Phase 3 – Privacy Policy

- [x] Write privacy policy (privacy-policy.html exists in project)
- [x] Host privacy policy online (required by Apple)
- [x] Add privacy policy URL to App Store Connect

---

## Phase 4 – Screenshots

- [x] Take iPhone 6.7" screenshots (1290 × 2796px)
- [x] Upload screenshots to App Store Connect

---

## Phase 5 – App Store Connect Listing (v1.0)

- [x] Create app in App Store Connect
- [x] Set categories: Primary = Productivity, Secondary = Health & Fitness
- [x] Set pricing to Free
- [x] Write and upload app description
- [x] Set age rating to 4+
- [x] Complete App Privacy (Data Not Collected)
- [x] Answer Export Compliance (No encryption)
- [x] Answer Advertising Identifier (No)

---

## Phase 6 – Build & Upload (v1.0 / v1.1)

- [x] Select "Any iOS Device (arm64)" in Xcode
- [x] Product → Archive
- [x] Validate archive in Xcode Organizer
- [x] Distribute → App Store Connect → Upload
- [x] Select build in App Store Connect
- [x] Submit for review
- [x] App approved and live on App Store ✅

---

## Phase 7 – App Store Optimization (v1.2) — IN PROGRESS

Goal: make the app discoverable when users search for "habit tracker", "habit", "discipline", "self improvement", "routine", etc.

- [x] Update app name to: `ChainHabit - Habit Tracker`
  - "habit" and "tracker" are now indexed by Apple search
- [x] Update subtitle to: `Build Discipline & Streaks`
  - Covers "discipline" and "streaks" search terms
- [x] Optimize keywords field (100 chars, no repeating words from name/subtitle):
  ```
  productivity,self improvement,routine,goals,motivation,daily,consistency,wellness,health,mindful
  ```
- [x] In Xcode: bump Version to 1.2, Build number to 2
- [ ] Select "Any iOS Device (arm64)"
- [ ] Product → Archive → Distribute → Upload
- [ ] Wait for build to process in App Store Connect (10–30 min)
- [ ] Select new build in the v1.2 version page
- [ ] Submit for review

---

## Phase 8 – Post-Launch: Improve Search Ranking

App Store search rank is driven by ratings and downloads, not just keywords.

- [x] Add `SKStoreReviewController.requestReview()` in Swift — trigger after a meaningful moment (e.g. user completes a 7-day streak)
  ```swift
  import StoreKit
  // Call this after user hits a milestone
  SKStoreReviewController.requestReview()
  ```
- [x] Ask friends and early users to leave a rating
- [x] Share on Reddit (r/iOS, r/SideProject), Twitter/X (#IndieDev), Product Hunt
- [x] Respond to all App Store reviews

---

## Key Facts

| Field | Value |
|---|---|
| App Name | ChainHabit - Habit Tracker |
| Subtitle | Build Discipline & Streaks |
| Bundle ID | com.krishnapradhan.HabitTrackerApp |
| Apple ID | 6770285086 |
| Categories | Productivity + Health & Fitness |
| Price | Free |
| Current Live Version | 1.1 |
| In-Progress Version | 1.2 (metadata update for ASO) |

---

## ASO Rule to Remember

Apple indexes **Name + Subtitle + Keywords** for search. Never repeat a word across all three — every character in the Keywords field should cover new search terms not already in the name or subtitle.
