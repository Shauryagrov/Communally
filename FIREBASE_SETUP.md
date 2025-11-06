# Firebase Setup Guide for Communally

## Overview
This guide will help you set up Firebase Firestore to enable real-time opportunity syncing across multiple devices.

## Problem Solved
- **Before**: Opportunities were saved locally on each device using UserDefaults
- **After**: Opportunities are synced in real-time through Firebase Firestore to all devices

---

## Step 1: Add Firebase SDK to Xcode

1. Open `Communally.xcodeproj` in Xcode
2. Go to **File** > **Add Package Dependencies...**
3. Enter the Firebase iOS SDK URL: 
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
4. Select **Version**: 11.0.0 or later
5. Click **Add Package**

6. In the package selection dialog, select these products:
   - ✅ **FirebaseCore**
   - ✅ **FirebaseFirestore**
   - ✅ **FirebaseAuth** (optional, for future authentication)
   
7. Click **Add Package**

---

## Step 2: Set Up Firebase Project

### 2.1 Create Firebase Project (if you haven't already)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** or select your existing project
3. Enter project name (e.g., "Communally")
4. Disable Google Analytics (optional)
5. Click **Create project**

### 2.2 Register iOS App

1. In Firebase Console, click the iOS+ icon to add an iOS app
2. Enter your **Bundle ID**: `shaurlabs.Communally`
3. Enter **App nickname** (optional): "Communally iOS"
4. Click **Register app**

### 2.3 Download GoogleService-Info.plist

1. **Download** the `GoogleService-Info.plist` file from Firebase Console
2. **Important**: Delete the existing placeholder file at:
   ```
   Communally/GoogleService-Info.plist
   ```
3. **Drag** the downloaded `GoogleService-Info.plist` into Xcode project
4. Make sure these options are checked:
   - ✅ **Copy items if needed**
   - ✅ **Add to targets: Communally**

---

## Step 3: Configure Firestore Database

### 3.1 Create Firestore Database

1. In Firebase Console, go to **Build** > **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```
4. Select a Cloud Firestore location (e.g., `us-central`)
5. Click **Enable**

### 3.2 Set Up Security Rules (Production)

⚠️ **Important**: Before launching to production, update your security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Opportunities collection
    match /opportunities/{opportunityId} {
      // Anyone can read opportunities
      allow read: if true;
      
      // Only authenticated users can create opportunities
      allow create: if request.auth != null;
      
      // Only the opportunity owner can update/delete
      allow update, delete: if request.auth != null 
                            && request.auth.uid == resource.data.hirerId;
    }
    
    // Applications collection (for future use)
    match /applications/{applicationId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null 
                           && request.auth.uid == resource.data.applicantId;
    }
  }
}
```

---

## Step 4: Create Firestore Indexes

To optimize queries, create these indexes:

1. In Firebase Console, go to **Firestore Database** > **Indexes**
2. Click **Create Index**
3. Add this index:
   - Collection ID: `opportunities`
   - Fields:
     - `createdAt` - Descending
     - `isActive` - Ascending
   - Query scope: Collection
4. Click **Create**

---

## Step 5: Build and Test

1. **Clean build folder**: Cmd+Shift+K in Xcode
2. **Build the project**: Cmd+B
3. **Run on Simulator 1**
4. **Run on Simulator 2** or a real device
5. **Test**:
   - Post an opportunity from Device 1
   - Check if it appears on Device 2 in real-time!

---

## What Was Changed in the Code

### Files Modified:

1. **`OpportunityManager.swift`**
   - Added Firebase Firestore import
   - Replaced UserDefaults with Firestore database
   - Added real-time listener for automatic updates
   - All CRUD operations now sync with Firestore

2. **`CommunallyApp.swift`**
   - Added Firebase initialization
   - Imports `FirebaseCore`

3. **`Opportunity` struct**
   - Added `@DocumentID` for Firestore document ID handling
   - Added `safeId` computed property for safe access

4. **`OpportunityDetailView.swift` & `ApplicantsListView.swift`**
   - Updated to use `safeId` instead of direct `id` access

---

## Troubleshooting

### Build Errors

**Error**: `No such module 'FirebaseFirestore'`
- **Solution**: Make sure you added the Firebase packages correctly in Step 1

**Error**: `Could not find GoogleService-Info.plist`
- **Solution**: Download the file from Firebase Console and add it to your Xcode project

### Runtime Errors

**Error**: Firestore operations timeout or fail
- **Solution**: Make sure your Firebase project has Firestore enabled
- Check your internet connection
- Verify the GoogleService-Info.plist has the correct PROJECT_ID

**Error**: Permission denied on Firestore operations
- **Solution**: Check your Firestore Security Rules in Firebase Console
- For development, use "test mode" rules

### No Data Syncing

1. Check Firebase Console > Firestore Database to see if data is being written
2. Check Xcode console for Firebase connection logs
3. Verify both devices have internet connection
4. Make sure `FirebaseApp.configure()` is called in `CommunallyApp.init()`

---

## Next Steps

Once Firebase is working:

1. **Enable offline persistence** for better performance:
   ```swift
   let settings = FirestoreSettings()
   settings.isPersistenceEnabled = true
   db.settings = settings
   ```

2. **Add Firebase Authentication** to replace mock authentication
3. **Add Cloud Functions** for server-side logic
4. **Add Firebase Storage** for profile pictures and images
5. **Add Firebase Cloud Messaging** for push notifications

---

## Cost Considerations

Firebase offers a generous free tier:
- **Firestore**: 50,000 reads/day, 20,000 writes/day
- **Storage**: 1 GB
- **Bandwidth**: 10 GB/month

For a small app, this should be sufficient. Monitor usage in Firebase Console.

---

## Support

If you encounter any issues:
1. Check the [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
2. Review [Firestore Getting Started Guide](https://firebase.google.com/docs/firestore/quickstart)
3. Check Firebase Console > Usage for quota/limits

---

**Good luck! 🚀**

