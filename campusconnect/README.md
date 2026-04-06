# 📱 CampusConnect - Student Social Media App

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**CampusConnect** is a student-focused social media platform designed for academic and campus interaction. Students can connect, share updates, post study-related content, and stay informed about campus activities.

---

## 🎯 Features

### Core Features (MVP)
- ✅ **Authentication**: Email/password signup, login, logout, password recovery
- ✅ **Home Feed**: View posts from all students in a social media style feed
- ✅ **Create Posts**: Share text and image posts with the community
- ✅ **Engagement**: Like and comment on posts
- ✅ **Profile Management**: View and edit user profiles
- ✅ **Media Upload**: Upload profile pictures and post images
- ✅ **Push Notifications**: Get notified about likes and comments

### User Information
Each student profile includes:
- Name
- Email
- Department
- Year of study
- Profile picture
- Bio

---

## 🏗️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Frontend** | Flutter (latest stable) |
| **Backend** | Firebase |
| **Authentication** | Firebase Auth |
| **Database** | Cloud Firestore |
| **Storage** | Firebase Storage |
| **Notifications** | Firebase Cloud Messaging |
| **State Management** | Provider |
| **Architecture** | MVVM Pattern |

---

## 📁 Project Structure

```
lib/
├── models/              # Data models (User, Post, Comment)
├── services/            # Firebase services (Auth, Firestore, Storage)
├── screens/             # UI screens (Login, Home, Profile, etc.)
├── widgets/             # Reusable UI components
├── providers/           # State management with Provider
├── utils/               # Constants, themes, helpers
└── main.dart            # App entry point

assets/
└── images/              # App images and icons
```

---

## 🚀 Setup Instructions

### Prerequisites

Before you begin, ensure you have:
- Flutter SDK installed ([Installation Guide](https://docs.flutter.dev/get-started/install))
- A code editor (VS Code or Android Studio recommended)
- Android Studio or Xcode for running on emulators
- A Firebase account ([Create one here](https://firebase.google.com/))

### Step 1: Clone and Install

```bash
# Navigate to the project directory
cd campusconnect

# Install dependencies
flutter pub get
```

### Step 2: Firebase Setup

#### A. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: **CampusConnect**
4. Follow the setup wizard (you can disable Google Analytics for now)
5. Click **"Create project"**

#### B. Enable Firebase Services

In your Firebase project:

1. **Authentication**:
   - Go to **Authentication** → **Sign-in method**
   - Enable **Email/Password**

2. **Firestore Database**:
   - Go to **Firestore Database** → **Create database**
   - Start in **Test mode** (for development)
   - Choose a location close to you

3. **Storage**:
   - Go to **Storage** → **Get started**
   - Start in **Test mode** (for development)

4. **Cloud Messaging**:
   - Already enabled by default

#### C. Configure Android App

1. In Firebase Console, click **Add app** → **Android**
2. Enter package name: `com.example.campusconnect`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`
5. Update `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

6. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21  // Important: Firebase requires min SDK 21
    }
}
```

#### D. Configure iOS App (Optional)

1. In Firebase Console, click **Add app** → **iOS**
2. Enter bundle ID: `com.example.campusconnect`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`
5. Update `ios/Podfile`:

```ruby
platform :ios, '12.0'  # Firebase requires iOS 12+
```

### Step 3: Run the App

```bash
# Check Flutter installation
flutter doctor

# Run on connected device or emulator
flutter run
```

---

## 🔥 Firebase Firestore Structure

### Collections

#### `users` Collection
```json
{
  "uid": "user123",
  "name": "John Doe",
  "email": "john@university.edu",
  "department": "Computer Science",
  "year": "3rd Year",
  "profileImage": "https://...",
  "bio": "CS student | Tech enthusiast",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### `posts` Collection
```json
{
  "postId": "post456",
  "userId": "user123",
  "username": "John Doe",
  "userProfileImage": "https://...",
  "text": "Just finished my final project!",
  "imageUrl": "https://...",
  "timestamp": "2024-01-20T14:20:00Z",
  "likesCount": 15,
  "likes": ["user789", "user456"],
  "commentsCount": 3
}
```

#### `comments` Collection
```json
{
  "commentId": "comment789",
  "postId": "post456",
  "userId": "user789",
  "username": "Jane Smith",
  "userProfileImage": "https://...",
  "text": "Congratulations!",
  "timestamp": "2024-01-20T15:00:00Z"
}
```

---

## 📦 Dependencies

All dependencies are defined in `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2           # Firebase SDK
  firebase_auth: ^4.15.3           # Authentication
  cloud_firestore: ^4.13.6         # Database
  firebase_storage: ^11.5.6        # File storage
  firebase_messaging: ^14.7.9      # Notifications
  provider: ^6.1.1                 # State management
  image_picker: ^1.0.7             # Image selection
  cached_network_image: ^3.3.1     # Image caching
  intl: ^0.18.1                    # Date formatting
  uuid: ^4.3.3                     # ID generation
  shimmer: ^3.0.0                  # Loading effects
```

---

## 🎨 App Architecture

This app follows **MVVM (Model-View-ViewModel)** architecture with **Provider** for state management:

- **Models**: Data classes (UserModel, PostModel, CommentModel)
- **Services**: Firebase interaction layer (Auth, Firestore, Storage)
- **Providers**: State management and business logic
- **Screens**: UI pages (Login, Home, Profile, etc.)
- **Widgets**: Reusable UI components

---

## 🔮 Future Features

The codebase is structured to support:
- 💬 Live chat between students
- 📅 Event management for campus activities
- 🤖 AI-based content moderation
- 👥 Groups and communities by department
- 🔍 Advanced search functionality
- 🌙 Dark mode

---

## 📝 Development Notes

### State Management with Provider

We use **Provider** because:
- ✅ Beginner-friendly and easy to understand
- ✅ Officially recommended by Flutter team
- ✅ Perfect for small to medium apps
- ✅ Less boilerplate than Bloc
- ✅ Good performance

### Code Style

- Follow Flutter naming conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Use `const` constructors where possible

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: "Firebase is not initialized"
- **Solution**: Make sure `Firebase.initializeApp()` is called in `main.dart`

**Issue**: "Gradle build failed"
- **Solution**: Check that `google-services.json` is in the correct location

**Issue**: "minSdkVersion error"
- **Solution**: Set `minSdkVersion 21` in `android/app/build.gradle`

**Issue**: Images not loading
- **Solution**: Check Firebase Storage rules and internet permissions

---

## 📄 License

This project is created for educational purposes as a semester project.

---

## 👨‍💻 Development Status

### ✅ Completed
- [x] Project setup and folder structure
- [x] Firebase configuration
- [x] Data models (User, Post, Comment)
- [x] App theme and constants
- [x] Splash screen

### 🚧 In Progress
- [ ] Authentication screens (Login, Sign Up)
- [ ] Home feed
- [ ] Post creation
- [ ] Profile management
- [ ] Notifications

---

## 🤝 Contributing

This is a semester project. For questions or issues, please contact the development team.

---

**Built with ❤️ using Flutter and Firebase**
