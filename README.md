# flutter-tiktok-clone

A short drama app MVP inspired by DramaBox, built with Flutter and Firebase.

## Features
- Black/red dark theme
- Vertical video feed
- Firebase anonymous auth
- Video upload to Firebase Storage
- Firestore-based drama episodes feed

## Setup
1. Install Flutter SDK.
2. Run:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   ```bash
   flutterfire configure
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Firebase Firestore structure
Use a collection named:

```text
drama_videos
```

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

## Notes
This is a lightweight MVP focused on feed + upload.
