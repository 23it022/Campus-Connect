# CampusConnect - Modular Architecture

## Overview

CampusConnect is a student-focused social media platform built with Flutter using a **modular architecture**. The app is organized into independent, reusable modules following clean architecture principles.

## Architecture Diagram

```
lib/
├── core/                          # Core infrastructure & utilities
├── shared/                        # Shared components across modules
├── features/                      # Feature modules (business logic)
│   ├── auth/
│   ├── feed/
│   ├── profile/
│   ├── events/
│   ├── groups/
│   ├── messaging/
│   └── notifications/
├── firebase_options.dart
└── main.dart
```

## Module Structure

Each feature module follows the **Clean Architecture** pattern with three layers:

### 1. Domain Layer (`domain/`)
- **Models**: Data entities (e.g., `UserModel`, `PostModel`)
- **Repositories**: Abstract interfaces for data operations

### 2. Data Layer (`data/`)
- **Services**: Concrete implementations of data operations
- **Repositories**: Implementation of domain repositories

### 3. Presentation Layer (`presentation/`)
- **Screens**: UI pages
- **Widgets**: Reusable UI components
- **Providers**: State management using Provider pattern

## Core Modules

### Core Infrastructure (`lib/core/`)

Provides fundamental infrastructure used across all features.

**Base Classes**:
- `BaseRepository`: Standard error handling for all repositories
- `BaseProvider`: Common state management patterns (loading, error states)

**Network**:
- `FirestoreService`: Centralized Firestore operations (CRUD, streams, transactions)
- `StorageService`: Firebase Storage operations (upload, download, URL generation)

**Errors**:
- `AppException`: Base exception class
- `NetworkException`, `AuthenticationException`, etc.

### Shared Module (`lib/shared/`)

Components used across multiple features.

**Theme** (`shared/theme/`):
- `themes.dart`: Light/dark theme configurations

**Constants** (`shared/constants/`):
- `constants.dart`: Colors, text styles, spacing, Firebase collection names

**Widgets** (`shared/widgets/`):
- `CustomButton`: Reusable button with loading states
- `CustomTextField`: Text input with validation
- `LoadingWidget`: Loading indicators and shimmer effects
- `ErrorWidget`: Error displays and empty states

**Navigation** (`shared/navigation/`):
- `AppRouter`: Centralized route management
- `NavigationService`: Context-independent navigation

## Feature Modules

### Authentication Module (`features/auth/`)

Complete authentication flow with Firebase Auth.

**Models**:
- `UserModel`: User profile data

**Services**:
- `AuthService`: Firebase authentication operations

**Providers**:
- `AuthProvider`: Authentication state management

**Screens**:
- `SplashScreen`: App startup
- `LoginScreen`: Email/password login
- `SignupScreen`: User registration
- `ForgotPasswordScreen`: Password reset

### Feed Module (`features/feed/`)

Social feed with posts, likes, and comments.

**Models**:
- `PostModel`: Social media post data
- `CommentModel`: Comment data

**Services**:
- `PostService`: Post CRUD operations, like/unlike
- `CommentService`: Comment operations

**Providers**:
- `FeedProvider`: Feed state management

**Screens** (To be implemented):
- `FeedScreen`: Display post feed
- `CreatePostScreen`: Create new posts
- `PostDetailScreen`: View post with comments

### Profile Module (`features/profile/`)

User profile management.

**Screens** (To be implemented):
- `ProfileScreen`: View user profile
- `EditProfileScreen`: Edit profile information

### Events Module (`features/events/`)

Campus events and activities.

**Models**:
- `EventModel`: Event data structure

**Screens** (To be implemented):
- `EventsScreen`: Browse events
- `EventDetailScreen`: View event details
- `CreateEventScreen`: Create new events

### Groups Module (`features/groups/`)

Student groups and communities.

**Models**:
- `GroupModel`: Group data structure

**Screens** (To be implemented):
- `GroupsScreen`: Browse groups
- `GroupDetailScreen`: View group details
- `CreateGroupScreen`: Create new groups

### Messaging Module (`features/messaging/`)

One-on-one and group messaging.

**Models**:
- `MessageModel`: Message data
- `ChatModel`: Conversation data

**Screens** (To be implemented):
- `ChatListScreen`: View all conversations
- `ChatScreen`: Message thread

### Notifications Module (`features/notifications/`)

Push and in-app notifications.

**Models**:
- `NotificationModel`: Notification data

**Screens** (To be implemented):
- `NotificationsScreen`: View all notifications

## State Management

The app uses **Provider** for state management with the following pattern:

1. **BaseProvider**: All providers extend this base class for common functionality
2. **Provider Hierarchy**: Providers can depend on other providers (e.g., FeedProvider depends on AuthProvider)
3. **Consumer Pattern**: UI rebuilds only when relevant data changes

### Provider Setup (main.dart)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProxyProvider<AuthProvider, FeedProvider>(
      create: (context) => FeedProvider(...),
      update: (_, auth, previous) => previous ?? FeedProvider(auth),
    ),
  ],
  child: MaterialApp(...),
)
```

## Firebase Setup

### Collections Structure

- `users`: User profiles
- `posts`: Social media posts
- `comments`: Post comments
- `notifications`: User notifications
- `events`: Campus events
- `groups`: Student groups
- `chats`: Conversations
- `messages`: Chat messages

### Storage Structure

- `users/{userId}/profile.jpg`: Profile images
- `posts/{userId}/{postId}.jpg`: Post images
- `events/{eventId}.jpg`: Event images
- `groups/{groupId}.jpg`: Group images

## Adding a New Feature Module

1. Create module directory structure:
   ```
   lib/features/new_feature/
   ├── domain/
   │   └── models/
   ├── data/
   │   └── services/
   └── presentation/
       ├── screens/
       ├── widgets/
       └── providers/
   ```

2. Create models in `domain/models/`
3. Create services in `data/services/`
4. Create provider in `presentation/providers/`
5. Create screens in `presentation/screens/`
6. Register provider in `main.dart`
7. Add routes in navigation module

## Best Practices

1. **Single Responsibility**: Each module handles one feature
2. **Dependency Injection**: Use providers for dependency management
3. **Error Handling**: Use try-catch and display user-friendly messages
4. **Loading States**: Show loading indicators during async operations
5. **Code Reusability**: Use shared widgets and base classes
6. **Type Safety**: Use strong typing and models
7. **Null Safety**: Handle nullable values properly

## Development Workflow

### Running the App

```bash
flutter run
```

### Building for Production

```bash
flutter build apk  # Android
flutter build ios  # iOS
flutter build windows  # Windows
```

### Testing

```bash
flutter test
```

## Dependencies

Key packages used:

- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `firebase_storage`: File storage
- `firebase_messaging`: Push notifications
- `provider`: State management
- `image_picker`: Image selection
- `cached_network_image`: Image caching
- `shimmer`: Loading effects
- `uuid`: Unique ID generation

## Future Enhancements

- [ ] Profile screens implementation
- [ ] Feed screens implementation
- [ ] Events screens implementation
- [ ] Groups screens implementation
- [ ] Messaging screens implementation
- [ ] Notifications screens implementation
- [ ] Search functionality
- [ ] Dark mode support
- [ ] Analytics integration
- [ ] Unit and widget tests
- [ ] CI/CD pipeline

## Contributing

When adding new features:

1. Follow the existing module structure
2. Use the base classes (BaseProvider, BaseRepository)
3. Update this README with new modules
4. Add appropriate comments and documentation

## License

This project is for educational purposes.
