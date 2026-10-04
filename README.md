# 🎬 DramaBox Clone - Short Drama App | Available for Freelance

> **Want an app like DramaBox / ReelShort? I build it for you!**
> 📩 Contact me on Fiverr / Upwork - Full Source Code + APK Available

[![Flutter](https://img.shields.io/badge/Flutter-3.22-blue)]()
[![Firebase](https://img.shields.io/badge/Firebase-Integrated-orange)]()

A short drama app MVP inspired by DramaBox, built with Flutter and Firebase.
Features infinite vertical video feed, like TikTok / DramaBox style.

### ✨ Features
- Black/red dark theme (DramaBox style)
- Vertical video feed
- Firebase anonymous auth
- Video upload to Firebase Storage
- Firestore-based drama episodes feed

### 🔥 Firestore Structure
Use a collection named: `drama_videos`

Each document should contain:
- `title: string`
- `description: string`
- `videoUrl: string`
- `thumbnailUrl: string`
- `ownerId: string`
- `ownerName: string`
- `likes: number`
- `comments: number`
- `createdAt: timestamp`

### 🚀 Setup
1. Install Flutter SDK
2. Run:
```bash
flutter pub get
