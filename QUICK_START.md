# 🚀 Quick Start - Firebase Setup (5 Steps)

## ⚡️ Fast Track to Get Syncing Working

### 1️⃣ Add Firebase to Xcode (2 min)
```
Xcode → File → Add Package Dependencies...
Paste: https://github.com/firebase/firebase-ios-sdk
Select: FirebaseCore + FirebaseFirestore
Click: Add Package
```

### 2️⃣ Create Firebase Project (3 min)
```
1. Go to: https://console.firebase.google.com/
2. Click: Add project
3. Name it: Communally
4. Click through setup (disable Analytics if asked)
```

### 3️⃣ Add iOS App to Firebase (2 min)
```
1. In Firebase Console, click: iOS+ icon
2. Bundle ID: shaurlabs.Communally
3. Click: Register app
4. Download: GoogleService-Info.plist
```

### 4️⃣ Replace Config File (1 min)
```
1. Delete: Communally/GoogleService-Info.plist (the placeholder)
2. Drag downloaded file into Xcode
3. Check: ✅ Copy items if needed
4. Check: ✅ Add to targets: Communally
```

### 5️⃣ Enable Firestore (2 min)
```
1. Firebase Console → Build → Firestore Database
2. Click: Create database
3. Choose: Test mode
4. Location: us-central (or closest to you)
5. Click: Enable
```

---

## ✅ Test It

```
1. Clean Build: Cmd+Shift+K
2. Build: Cmd+B
3. Run on Device/Simulator 1
4. Run on Device/Simulator 2
5. Post opportunity on Device 1
6. Watch it appear on Device 2! 🎉
```

---

## 🆘 Troubleshooting

**Build error?**
- Make sure Firebase packages were added correctly (Step 1)

**Runtime crash?**
- Check GoogleService-Info.plist is in project (Step 4)
- Verify Firestore is enabled (Step 5)

**No syncing?**
- Check internet connection
- Check Firebase Console → Firestore to see if data appears
- Check Xcode console for Firebase connection logs

---

## 📚 Detailed Guides

- **Full Instructions**: Read `FIREBASE_SETUP.md`
- **What Changed**: Read `SYNC_FIX_SUMMARY.md`
- **Firebase Docs**: https://firebase.google.com/docs/ios/setup

---

**Total Time: ~10 minutes**

Let's go! 🚀

