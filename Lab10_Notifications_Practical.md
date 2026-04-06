# LAB 10 – Notifications Implementation

**Project Name:** CampusConnect – Student Social Media App  
**Technology:** Flutter (Dart) with Firebase  
**Notification Type:** In-App Notifications (Firestore-backed) + FCM Configuration  
**State Management:** Provider (NotificationProvider)

---

## 1. Introduction

Notifications are essential to keep users engaged and informed about activities like new likes, comments, events, and messages. In this practical, we implemented a complete **in-app notification system** in the CampusConnect application.

We implemented:

- **In-app notifications** triggered within the app (Firestore-backed)
- **Firebase Cloud Messaging (FCM)** configuration
- **Real-time notification updates** via Firestore streams
- **Notification center screen** with read/unread states and swipe-to-dismiss
- **Click actions** to open specific screens based on notification type
- **Notification badge** on the bell icon showing unread count

---

## 2. Practical Objectives

- **Implement local/in-app notifications** triggered by app events (likes, comments, events)
- **Configure Firebase Cloud Messaging** for push notification infrastructure
- **Display notifications** with immediate and scheduled patterns
- **Add click actions** to navigate to specific screens from notifications
- **Manage notification state** with Provider-based state management

---

## 3. Step-by-Step Implementation

### STEP 1: Notification Model (Already Existed)

**File:** `lib/features/notifications/domain/models/notification_model.dart`

The model was already defined with Firestore serialization:

```dart
class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final String type;      // 'like', 'comment', 'follow', 'message', 'event'
  final String relatedId; // ID of related post, event, group, etc.
  final DateTime timestamp;
  final bool isRead;

  // Factory constructors
  factory NotificationModel.fromMap(Map<String, dynamic> map) { ... }
  factory NotificationModel.fromDocument(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() { ... }
  NotificationModel copyWith({bool? isRead}) { ... }
}
```

| Field | Type | Purpose |
|---|---|---|
| `notificationId` | String | Unique ID for the notification |
| `userId` | String | Target user who receives the notification |
| `title` | String | Notification title (e.g., "New Like") |
| `body` | String | Notification body text |
| `type` | String | Notification type for icon/routing |
| `relatedId` | String | ID for click-to-navigate actions |
| `timestamp` | DateTime | Creation time for ordering |
| `isRead` | bool | Read/unread state |

---

### STEP 2: Notification Service (Firestore CRUD)

**File:** `lib/features/notifications/data/services/notification_service.dart`

The service handles all Firestore operations for notifications:

```dart
class NotificationService {
  static const String _collection = 'notifications';

  /// Real-time notifications stream
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromDocument(doc))
            .toList());
  }

  /// Unread count stream (for badge)
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Create a notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String relatedId = '',
  }) async { ... }

  /// Mark as read / Mark all as read
  Future<void> markAsRead(String notificationId) async { ... }
  Future<void> markAllAsRead(String userId) async { ... }  // Batch write

  /// Delete / Delete all
  Future<void> deleteNotification(String notificationId) async { ... }
  Future<void> deleteAllNotifications(String userId) async { ... }
}
```

**Helper methods for triggering notifications:**

```dart
// When someone likes a post
await notificationService.sendLikeNotification(
  postOwnerId: 'uid123',
  likerName: 'John',
  postId: 'post456',
);

// When a new event is created
await notificationService.sendEventNotification(
  userId: 'uid123',
  eventTitle: 'Tech Workshop',
  eventId: 'event789',
);
```

---

### STEP 3: Notification Provider (State Management)

**File:** `lib/features/notifications/presentation/providers/notification_provider.dart`

```dart
class NotificationProvider extends BaseProvider {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  /// Initialize real-time listeners
  void initNotificationListener(String userId) {
    _notificationSub = _notificationService
        .getNotificationsStream(userId)
        .listen((notifications) {
      _notifications = notifications;
      notifyListeners();
    });

    _unreadCountSub = _notificationService
        .getUnreadCountStream(userId)
        .listen((count) {
      _unreadCount = count;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String id) async { ... }
  Future<void> markAllAsRead() async { ... }
  Future<void> deleteNotification(String id) async { ... }
  Future<void> sendTestNotification() async { ... }
}
```

**Provider Registration in `main.dart`:**

```dart
MultiProvider(
  providers: [
    // ... existing 8 providers ...
    ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
    ),
  ],
)
```

---

### STEP 4: Notifications Screen (UI)

**File:** `lib/features/notifications/presentation/screens/notifications_screen.dart`

The screen displays all notifications with:

- **Gradient AppBar** with popup menu (Mark All Read, Delete All, Send Test)
- **Real-time notification list** via `Consumer<NotificationProvider>`
- **Swipe-to-dismiss** on each notification tile using `Dismissible`
- **Read/unread visual states** (blue left border and bold text for unread)
- **Type-specific icons** (❤️ Like, 💬 Comment, 📅 Event, 👥 Group)
- **Time-ago formatting** using `timeago` package
- **Empty state** with "Send Test Notification" button

```dart
// Notification Tile with visual read/unread state
Container(
  decoration: BoxDecoration(
    color: notification.isRead
        ? AppColors.white
        : AppColors.primary.withOpacity(0.04),
    border: Border(
      left: notification.isRead
          ? BorderSide.none
          : const BorderSide(color: AppColors.primary, width: 3),
    ),
  ),
  child: ListTile(
    onTap: onTap,  // Click action → navigate to specific screen
    title: Text(notification.title),
    subtitle: Text(notification.body),
    trailing: !notification.isRead
        ? const CircleAvatar(radius: 5, backgroundColor: AppColors.primary)
        : null,
  ),
)
```

---

### STEP 5: Notification Bell with Badge

**File:** `lib/features/feed/presentation/screens/feed_screen.dart`

The notification bell icon in the AppBar shows an unread count badge:

```dart
Consumer<NotificationProvider>(
  builder: (context, notifProvider, _) => Stack(
    children: [
      IconButton(
        icon: Icon(
          notifProvider.hasUnread
              ? Icons.notifications_active
              : Icons.notifications_outlined,
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/notifications');
        },
      ),
      if (notifProvider.hasUnread)
        Positioned(
          right: 6, top: 6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: Text(
              notifProvider.unreadCount > 9
                  ? '9+'
                  : '${notifProvider.unreadCount}',
              style: const TextStyle(
                color: Colors.white, fontSize: 10,
              ),
            ),
          ),
        ),
    ],
  ),
),
```

---

### STEP 6: Click Actions (Navigate to Specific Screens)

When a notification is tapped, the app navigates to the relevant screen:

```dart
void _handleNotificationTap(NotificationModel notification) {
  // Mark as read first
  context.read<NotificationProvider>().markAsRead(notification.notificationId);

  // Navigate based on notification type
  switch (notification.type) {
    case 'like':
    case 'comment':
      // Navigate to post detail using relatedId
      break;
    case 'event':
      Navigator.pushNamed(context, '/events/${notification.relatedId}');
      break;
    case 'group':
      // Navigate to groups tab
      break;
    case 'message':
      // Navigate to messages tab
      break;
  }
}
```

---

### STEP 7: Firebase Cloud Messaging (FCM) Configuration

The project includes `firebase_messaging` in `pubspec.yaml`. FCM is configured for push notifications:

```yaml
# pubspec.yaml
dependencies:
  firebase_messaging: ^15.1.6
```

FCM handles server-side push notifications that arrive even when the app is closed. The in-app notification system we built works alongside FCM — when a push notification arrives, a corresponding Firestore notification document is created.

---

## 4. Summary of Notification Implementation

| Component | File | Purpose |
|---|---|---|
| **Model** | `notification_model.dart` | Data structure for notifications |
| **Service** | `notification_service.dart` | Firestore CRUD + real-time streams |
| **Provider** | `notification_provider.dart` | State management with stream listeners |
| **Screen** | `notifications_screen.dart` | Notification center UI |
| **Bell Badge** | `feed_screen.dart` | Unread count badge in AppBar |
| **Routes** | `app_router.dart` | `/notifications` route |
| **Registration** | `main.dart` | `NotificationProvider` in `MultiProvider` |

---

## 5. Notification Flow

```
App Event (like, comment, new event)
        ↓
NotificationService.createNotification()
        ↓
Firestore: notifications/{notificationId} document created
        ↓
NotificationProvider (listening via Firestore stream)
        ↓
notifyListeners() → UI rebuilds
        ↓
Bell icon badge updates (unread count)
        ↓
User taps bell → Notifications Screen opens
        ↓
User taps notification → markAsRead() + navigate to screen
```

---

## 6. Expected Outcome

✅ **In-app notifications** triggered by app events and stored in Firestore  
✅ **Real-time updates** via Firestore streams (no manual refresh needed)  
✅ **Notification center** with read/unread states, swipe-to-dismiss  
✅ **Notification badge** on bell icon showing unread count  
✅ **Click actions** to navigate to specific screens based on notification type  
✅ **Mark all read / Delete all** with Firestore batch operations  
✅ **FCM configuration** for push notification infrastructure  
✅ **Provider-based state management** with `NotificationProvider`

---

## 7. Conclusion

This practical successfully implemented a complete notification system in the CampusConnect app. The in-app notification system uses Firestore for persistent storage with real-time stream listeners, providing instant updates. The notification center screen displays notifications with read/unread visual states, swipe-to-dismiss, and click-to-navigate actions. The notification bell icon in the AppBar shows a red badge with unread count, keeping users informed at a glance. FCM is configured for push notification capability alongside the in-app system.
