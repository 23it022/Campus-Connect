# 🔥 Firebase Setup Guide for CampusConnect

This guide will walk you through setting up Firebase for the CampusConnect app step-by-step.

---

## ⚠️ IMPORTANT: Read Before Starting

**You MUST complete Firebase setup before running the app**, otherwise you'll get Firebase initialization errors.

---

## 📋 Step-by-Step Firebase Setup

### Step 1: Create a Firebase Project

1. Go to **[Firebase Console](https://console.firebase.google.com/)**
2. Click **"Add project"** or **"Create a project"**
3. Enter Project Name: `CampusConnect`
4. Click **Continue**
5. **Google Analytics**: You can disable it for now (optional)
6. Click **Create project**
7. Wait for the project to be created
8. Click **Continue** when done

---

### Step 2: Enable Firebase Services

#### A. Enable Authentication

1. In your Firebase project, click **Authentication** in the left sidebar
2. Click **Get started**
3. Go to **Sign-in method** tab
4. Click on **Email/Password**
5. Toggle **Enable** switch ON
6. Click **Save**

✅ **Authentication is now enabled!**

#### B. Create Firestore Database

1. Click **Firestore Database** in the left sidebar
2. Click **Create database**
3. Choose **Start in test mode** (for development)
   ```
   Note: Test mode allows read/write access. 
   We'll add security rules later.
   ```
4. Select a **Firestore location** (choose one closest to you)
5. Click **Enable**
6. Wait for database creation

✅ **Firestore Database is ready!**

#### C. Enable Firebase Storage

1. Click **Storage** in the left sidebar
2. Click **Get started**
3. Start in **test mode**
4. Use the same location as Firestore
5. Click **Done**

✅ **Firebase Storage is ready!**

#### D. Enable Cloud Messaging

1. Click **Cloud Messaging** in the left sidebar
2. It's already enabled by default! ✅

---

### Step 3: Register Android App with Firebase

1. In Firebase project overview, click the **Android icon** (🤖)
2. **Register app** form will appear:

   **Android package name**: `com.example.campusconnect`
   
   **App nickname** (optional): `CampusConnect Android`
   
   **Debug signing certificate SHA-1** (optional): Leave empty for now
   
3. Click **Register app**

4. **Download google-services.json**:
   - Click **Download google-services.json**
   - Save the file

5. **Add to project**:
   - Copy `google-services.json` to:
     ```
     campusconnect/android/app/google-services.json
     ```
   - ⚠️ **CRITICAL**: File must be in `android/app/` folder!

6. Click **Next** → **Next** → **Continue to console**

✅ **Android app is registered!**

---

### Step 4: Register iOS App (Optional, if you have macOS)

1. In Firebase project overview, click the **iOS icon** (🍎)
2. **Register app** form:

   **iOS bundle ID**: `com.example.campusconnect`
   
   **App nickname** (optional): `CampusConnect iOS`
   
3. Click **Register app**

4. **Download GoogleService-Info.plist**:
   - Click **Download GoogleService-Info.plist**
   - Save the file

5. **Add to project**:
   - Copy `GoogleService-Info.plist` to:
     ```
     campusconnect/ios/Runner/GoogleService-Info.plist
     ```

6. Click **Next** → **Next** → **Next** → **Continue to console**

✅ **iOS app is registered!**

---

### Step 5: Update Firestore Security Rules (Important!)

By default, test mode rules expire after 30 days. Let's set proper development rules:

1. Go to **Firestore Database** → **Rules** tab
2. Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                              request.auth.uid == resource.data.userId;
    }
    
    // Comments collection
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                              request.auth.uid == resource.data.userId;
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if request.auth != null && 
                     request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                              request.auth.uid == resource.data.userId;
    }
  }
}
```

3. Click **Publish**

✅ **Security rules updated!**

---

### Step 6: Update Storage Security Rules

1. Go to **Storage** → **Rules** tab
2. Replace the rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Post images
    match /post_images/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click **Publish**

✅ **Storage rules updated!**

---

## ✅ Verification Checklist

Before running the app, verify:

- [ ] Firebase project created
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore Database created (test mode)
- [ ] Firebase Storage enabled
- [ ] Android app registered
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] Firestore security rules updated
- [ ] Storage security rules updated

---

## 🚀 Next Steps

Once Firebase is set up:

1. **Install Flutter dependencies**:
   ```bash
   cd campusconnect
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🐛 Troubleshooting

### Error: "FirebaseException: No Firebase App"

**Solution**: Make sure `google-services.json` is in `android/app/` folder

### Error: "Duplicate class found"

**Solution**: Run:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Error: "minSdkVersion is less than 21"

**Solution**: Already configured in `android/app/build.gradle` as minSdkVersion 21

### Error: "PERMISSION_DENIED: Missing or insufficient permissions"

**Solution**: Check Firestore security rules are published correctly

---

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Data Modeling Guide](https://firebase.google.com/docs/firestore/data-model)

---

## 🔐 Security Notes for Production

⚠️ **Before deploying to production**:

1. Update Firestore rules to be more restrictive
2. Update Storage rules to validate file types and sizes
3. Enable App Check for additional security
4. Set up proper authentication flows
5. Enable Firebase Analytics for monitoring

---

**🎉 Firebase setup complete! You're ready to build CampusConnect!**
