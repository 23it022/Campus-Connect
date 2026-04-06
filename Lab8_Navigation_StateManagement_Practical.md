# LAB 8 – Navigation & State Management

**Project Name:** CampusConnect – Student Social Media App  
**Technology:** Flutter (Dart) with Firebase  
**State Management:** Provider (ChangeNotifier + MultiProvider)  
**Navigation:** Named Routes with onGenerateRoute & NavigationService

---

## 1. Introduction

Navigation and State Management are two critical pillars of any mobile application. **Navigation** enables users to move seamlessly between screens, while **State Management** ensures that data persists, updates, and reacts across the entire application.

In this practical, we implemented the following in the **CampusConnect** application:

- **Multi-screen navigation** using named routes and a centralized `AppRouter`
- **Data passing between screens** via route arguments (e.g., `PostModel`, `eventId`, `ticketId`)
- **Global user/session state** managed through `AuthProvider` with `ChangeNotifier`
- **CRUD state handling** for posts, events, groups, feedback, and support tickets using dedicated providers
- **Bottom Navigation Bar** with 5 animated tabs for primary navigation
- **Provider** as the app-wide state management solution (`MultiProvider`, `ChangeNotifierProvider`, `ChangeNotifierProxyProvider`, `Consumer`, `context.watch`, `context.read`)

The app features **36+ screens** across **17 feature modules**, all connected through a centralized routing system and managed by **7 providers**.

---

## 2. Practical Objectives

By completing this practical, we achieved the following:

- **Implemented multi-screen navigation** – Centralized route definitions with `AppRoutes`, `AppRouter`, and `NavigationService`
- **Passed data between screens** – Using `Navigator.pushNamed()` with `arguments` parameter and `RouteSettings`
- **Maintained global user/session state** – `AuthProvider` tracks the authenticated user across all screens
- **Handled CRUD state updates** – `FeedProvider`, `EventProvider`, `ProfileProvider`, and `GroupProvider` manage Create, Read, Update, Delete operations
- **Used Bottom Navigation Bar** – 5 animated tabs (Feed, Events, Groups, Messages, Profile) in `HomeScreen`
- **Introduced Provider** – Flutter's recommended state management approach using `ChangeNotifier`, `MultiProvider`, and `Consumer` widgets

---

## 3. Step-by-Step Implementation

### STEP 1: Centralized Route Management (`AppRouter`)

All routes are defined in a single `AppRoutes` class for type-safe navigation:

**File:** `lib/shared/navigation/app_router.dart`

```dart
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String home = '/home';

  // Feed routes
  static const String createPost = '/create-post';
  static const String postDetail = '/post-detail';
  static const String bookmarks = '/bookmarks';
  static const String editPost = '/edit-post';

  // Events routes
  static const String eventDetail = '/event-detail';
  static const String createEvent = '/create-event';

  // Groups routes
  static const String groups = '/groups';
  static const String groupDetail = '/group-detail';
  static const String createGroup = '/create-group';

  // Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String rateFeedback = '/rate-feedback';
  static const String helpSupport = '/help-support';
  static const String createSupportTicket = '/create-support-ticket';
  static const String supportTicketDetail = '/support-ticket-detail';
  static const String settings = '/settings';

  // Teacher routes
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherLogin = '/teacher/login';
  static const String teacherSignup = '/teacher/signup';
}
```

#### Static Routes Map

Routes that don't require arguments are registered in `getRoutes()`:

```dart
class AppRouter {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppRoutes.splash: (context) => const SplashScreen(),
      AppRoutes.login: (context) => const LoginScreen(),
      AppRoutes.signup: (context) => const SignupScreen(),
      AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
      AppRoutes.home: (context) => const HomeScreen(),
      AppRoutes.createPost: (context) => const CreatePostScreen(),
      AppRoutes.bookmarks: (context) => const BookmarksScreen(),
      AppRoutes.createEvent: (context) => const CreateEventScreen(),
      AppRoutes.rateFeedback: (context) => const RateFeedbackScreen(),
      AppRoutes.helpSupport: (context) => const HelpSupportScreen(),
      AppRoutes.createSupportTicket: (context) => const CreateSupportTicketScreen(),
      AppRoutes.settings: (context) => const SettingsScreen(),
      AppRoutes.teacherDashboard: (context) => const TeacherDashboardScreen(),
      AppRoutes.teacherLogin: (context) => const TeacherLoginScreen(),
      AppRoutes.teacherSignup: (context) => const TeacherSignupScreen(),
    };
  }
}
```

#### MaterialApp Configuration

In `main.dart`, routes are connected to `MaterialApp`:

```dart
MaterialApp(
  title: AppStrings.appName,
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme,
  navigatorKey: NavigationService.navigatorKey,
  initialRoute: AppRoutes.splash,
  routes: AppRouter.getRoutes(),
  onGenerateRoute: AppRouter.generateRoute,
)
```

---

### STEP 2: Passing Data Between Screens (`onGenerateRoute`)

For screens that require data, we use `onGenerateRoute` with `RouteSettings.arguments`:

**File:** `lib/shared/navigation/app_router.dart`

#### Passing a PostModel to Post Detail Screen

```dart
// Sender: Feed Screen
Navigator.pushNamed(
  context,
  AppRoutes.postDetail,
  arguments: post,  // Passing PostModel object
);

// Receiver: AppRouter.generateRoute()
static Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.postDetail:
      final post = settings.arguments as PostModel?;
      if (post == null) {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Post not found')),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      );
  }
}
```

#### Passing EventId via Dynamic URL Segments

```dart
// Sender: Events Screen
Navigator.pushNamed(context, '/events/$eventId');

// Receiver: AppRouter.generateRoute() – URL parsing
if (settings.name?.startsWith('/events/') ?? false) {
  final segments = settings.name!.split('/');
  if (segments.length >= 3) {
    final eventId = segments[2];

    // Edit event route (/events/{id}/edit)
    if (segments.length == 4 && segments[3] == 'edit') {
      return MaterialPageRoute(
        builder: (_) => CreateEventScreen(eventId: eventId),
      );
    }

    // Event detail route (/events/{id})
    return MaterialPageRoute(
      builder: (_) => EventDetailScreen(eventId: eventId),
    );
  }
}
```

#### Passing TicketId as Route Argument

```dart
// Sender: Help & Support Screen
Navigator.pushNamed(
  context,
  AppRoutes.supportTicketDetail,
  arguments: ticketId,  // Passing String ticketId
);

// Receiver: AppRouter.generateRoute()
if (settings.name == AppRoutes.supportTicketDetail) {
  final ticketId = settings.arguments as String?;
  if (ticketId == null) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text('Ticket not found'))),
    );
  }
  return MaterialPageRoute(
    builder: (_) => SupportTicketDetailScreen(ticketId: ticketId),
  );
}
```

---

### STEP 3: Context-Independent Navigation Service

**File:** `lib/shared/navigation/navigation_service.dart`

The `NavigationService` is a **singleton** that enables navigation from anywhere in the app (including services and providers) without needing a `BuildContext`:

```dart
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  /// Replace current route
  Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Pop current route
  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  /// Pop until a specific route
  void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  /// Navigate and remove all previous routes
  Future<dynamic> navigateAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
```

**Usage: The `navigatorKey` is connected to `MaterialApp`:**

```dart
MaterialApp(
  navigatorKey: NavigationService.navigatorKey,
  // ...
)
```

---

### STEP 4: Bottom Navigation Bar (5-Tab Navigation)

**File:** `lib/features/home/presentation/screens/home_screen.dart`

The `HomeScreen` implements a custom animated Bottom Navigation Bar with 5 tabs, using `setState` for local tab state:

```dart
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 5 screens mapped to tabs
  final List<Widget> _screens = [
    const FeedScreen(),
    const EventsScreen(),
    const GroupsScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  final List<String> _labels = ['Feed', 'Events', 'Groups', 'Messages', 'Profile'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => _onItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppGradients.button : null,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? _icons[index] : _outlinedIcons[index],
                        color: isSelected ? AppColors.white : AppColors.grey,
                      ),
                      if (isSelected)
                        Text(_labels[index],
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      // FAB on Feed tab only
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/create-post'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
```

---

### STEP 5: Auth-Based Conditional Navigation (Splash Screen)

**File:** `lib/features/auth/presentation/screens/splash_screen.dart`

The Splash Screen checks authentication state via `AuthProvider` and navigates accordingly:

```dart
Future<void> _navigateToNextScreen() async {
  await Future.delayed(const Duration(seconds: 3));

  if (mounted) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');     // → Home Screen
    } else {
      Navigator.pushReplacementNamed(context, '/login');    // → Login Screen
    }
  }
}
```

**Navigation Flow:**

```
App Launch → SplashScreen (/ )
                ↓
        Check AuthProvider.isAuthenticated
               ↓                    ↓
        (Authenticated)       (Not Authenticated)
               ↓                    ↓
          HomeScreen           LoginScreen
          (/home)               (/login)
               ↓                    ↓
    Bottom Nav (5 tabs)    SignupScreen (/signup)
                           ForgotPasswordScreen (/forgot-password)
```

---

### STEP 6: State Management with Provider

#### 6.1 – BaseProvider (Foundation Pattern)

**File:** `lib/core/base/base_provider.dart`

All providers extend `BaseProvider`, which provides common loading, error, and async operation handling:

```dart
class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Execute an async operation with automatic loading and error handling
  Future<T?> executeOperation<T>(Future<T> Function() operation) async {
    try {
      setLoading(true);
      clearError();
      final result = await operation();
      setLoading(false);
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }
}
```

#### 6.2 – MultiProvider Setup (App-Wide State)

**File:** `lib/main.dart`

All 7 providers are registered at the top of the widget tree using `MultiProvider`:

```dart
class CampusConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider (independent) – manages user session
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initAuthListener(),
        ),

        // Feed Provider (depends on Auth) – manages posts CRUD
        ChangeNotifierProxyProvider<AuthProvider, FeedProvider>(
          create: (context) => FeedProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (_, auth, previous) => previous ?? FeedProvider(auth),
        ),

        // Event Provider – manages events CRUD
        ChangeNotifierProvider(create: (_) => EventProvider()),

        // Profile Provider – manages feedback & support tickets
        ChangeNotifierProvider(create: (_) => ProfileProvider()),

        // Messaging Provider – manages chat state
        ChangeNotifierProvider(create: (_) => MessagingProvider()),

        // Group Provider – manages study groups
        ChangeNotifierProvider(create: (_) => GroupProvider()),

        // Teacher Provider – manages teacher-specific data
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
      ],
      child: MaterialApp(/* ... */),
    );
  }
}
```

#### 6.3 – Global User/Session State (AuthProvider)

**File:** `lib/features/auth/presentation/providers/auth_provider.dart`

`AuthProvider` manages authentication state globally and is accessed across all screens:

```dart
class AuthProvider extends BaseProvider {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Listen to Firebase auth state changes
  void initAuthListener() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _currentUser = await _authService.getUserProfile(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();  // Notify all listening widgets
    });
  }

  /// Sign in – updates global user state
  Future<bool> signIn({required String email, required String password}) async {
    final result = await executeOperation(() async {
      final user = await _authService.signIn(email: email, password: password);
      _currentUser = user;
      return user;
    });
    return result != null;
  }

  /// Sign out – clears global user state
  Future<void> signOut() async {
    await executeOperation(() async {
      await _authService.signOut();
      _currentUser = null;
    });
  }
}
```

**Accessing Global User State from Any Screen:**

```dart
// Read user data (Profile Screen)
final user = context.watch<AuthProvider>().currentUser;

// Read without listening (one-time access)
final authProvider = context.read<AuthProvider>();

// Use Consumer for granular rebuilds (Login Screen)
Consumer<AuthProvider>(
  builder: (context, auth, _) => CustomButton(
    text: 'Login',
    onPressed: _handleLogin,
    isLoading: auth.isLoading,
  ),
),
```

---

### STEP 7: CRUD State Management (FeedProvider Example)

**File:** `lib/features/feed/presentation/providers/feed_provider.dart`

The `FeedProvider` demonstrates full CRUD state management with filtering:

```dart
class FeedProvider extends BaseProvider {
  final PostService _postService = PostService();
  final AuthProvider _authProvider;

  List<PostModel> _posts = [];
  FeedFilter _currentFilter = FeedFilter.all;

  FeedProvider(this._authProvider) {
    _initFeedListener();  // Real-time updates via Firestore stream
  }

  /// CREATE – Add a new post
  Future<bool> createPost({required String text, String? imageUrl}) async {
    final user = _authProvider.currentUser;
    if (user == null) { setError('Please login'); return false; }

    final post = PostModel(
      postId: const Uuid().v4(),
      userId: user.uid,
      username: user.name,
      text: text,
      imageUrl: imageUrl ?? '',
    );
    await executeOperation(() => _postService.createPost(post));
    return !isLoading && errorMessage.isEmpty;
  }

  /// READ – Real-time feed listener
  void _initFeedListener() {
    _postService.getPostsStream().listen((posts) {
      _posts = posts;
      _applyFilters();  // Re-apply current filter
    });
  }

  /// UPDATE – Edit a post
  Future<bool> editPost(String postId, String newText, {String? newImageUrl}) async {
    await executeOperation(
      () => _postService.editPost(postId, newText, newImageUrl: newImageUrl),
    );
    return !isLoading && errorMessage.isEmpty;
  }

  /// DELETE – Remove a post
  Future<bool> deletePost(String postId) async {
    await executeOperation(() => _postService.deletePost(postId));
    return !isLoading && errorMessage.isEmpty;
  }

  /// Toggle like (state update with optimistic UI)
  Future<void> toggleLike(PostModel post) async {
    final user = _authProvider.currentUser;
    if (user == null) return;

    if (post.isLikedBy(user.uid)) {
      await executeOperation(() => _postService.unlikePost(post.postId, user.uid));
    } else {
      await executeOperation(() => _postService.likePost(post.postId, user.uid));
    }
  }

  /// Filter management
  void setFilter(FeedFilter filter) {
    _currentFilter = filter;
    _applyFilters();
  }
}
```

#### CRUD State in EventProvider

**File:** `lib/features/events/presentation/providers/event_provider.dart`

```dart
class EventProvider extends BaseProvider {
  List<EventModel> _allEvents = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _myEvents = [];

  /// CREATE – New event
  Future<bool> createEvent(EventModel event) async { /* ... */ }

  /// READ – Load all events
  Future<void> loadAllEvents() async { /* ... */ }

  /// UPDATE – Modify event
  Future<bool> updateEvent(EventModel event) async { /* ... */ }

  /// DELETE – Remove event & update all local lists
  Future<bool> deleteEvent(String eventId) async {
    final result = await executeOperation(() async {
      await _eventService.deleteEvent(eventId);
      _removeEventFromLists(eventId);  // Update all cached lists
      notifyListeners();
      return true;
    });
    return result ?? false;
  }

  /// Helper: keep all local lists in sync
  void _removeEventFromLists(String eventId) {
    _allEvents.removeWhere((e) => e.eventId == eventId);
    _upcomingEvents.removeWhere((e) => e.eventId == eventId);
    _myEvents.removeWhere((e) => e.eventId == eventId);
    _attendingEvents.removeWhere((e) => e.eventId == eventId);
  }
}
```

---

### STEP 8: Dependent Providers (ChangeNotifierProxyProvider)

The `FeedProvider` depends on `AuthProvider` to access the current user. This dependency is wired using `ChangeNotifierProxyProvider`:

```dart
// In main.dart – FeedProvider receives AuthProvider as dependency
ChangeNotifierProxyProvider<AuthProvider, FeedProvider>(
  create: (context) => FeedProvider(
    Provider.of<AuthProvider>(context, listen: false),
  ),
  update: (_, auth, previous) => previous ?? FeedProvider(auth),
),
```

**How it works:**
1. `AuthProvider` is created first (independent)
2. `FeedProvider` is created with a reference to `AuthProvider`
3. When `AuthProvider` updates, `FeedProvider` can access the latest user data
4. `FeedProvider` uses `_authProvider.currentUser` in CRUD operations

---

### STEP 9: Navigation Patterns Summary

| Navigation Pattern | Usage | Example |
|---|---|---|
| **`Navigator.pushNamed()`** | Navigate to a screen | `Navigator.pushNamed(context, '/create-post')` |
| **`Navigator.pushNamed()` with arguments** | Pass data to screen | `Navigator.pushNamed(context, '/post-detail', arguments: post)` |
| **`Navigator.pushReplacementNamed()`** | Replace current screen (auth flow) | `Navigator.pushReplacementNamed(context, '/home')` |
| **`Navigator.pop()`** | Go back to previous screen | `Navigator.pop(context)` |
| **`Navigator.pop()` with result** | Return data from dialog | `Navigator.pop(context, true)` |
| **`Navigator.pushNamedAndRemoveUntil()`** | Clear entire stack (logout) | `NavigationService().navigateAndRemoveUntil('/login')` |
| **Dynamic URL routing** | Parse route segments | `/events/{eventId}`, `/events/{eventId}/edit` |
| **Bottom Navigation** | Switch between tabs | `setState(() => _selectedIndex = index)` |
| **`context.read<Provider>()`** | Access state without listening | `context.read<AuthProvider>().signOut()` |
| **`context.watch<Provider>()`** | Access state with rebuild on change | `context.watch<AuthProvider>().currentUser` |

---

## 4. Architecture Overview – Providers

| Provider | Purpose | Key State | CRUD Operations |
|---|---|---|---|
| **AuthProvider** | Global user/session state | `currentUser`, `isAuthenticated` | Sign up, Sign in, Sign out, Reset password |
| **FeedProvider** | Feed posts management | `posts`, `currentFilter`, `trendingHashtags` | Create, Read (stream), Edit, Delete, Like, Bookmark, Report |
| **EventProvider** | Events management | `allEvents`, `upcomingEvents`, `myEvents` | Create, Read, Update, Delete, Toggle attendance |
| **ProfileProvider** | Feedback & support tickets | `userFeedback`, `userTickets`, `averageRating` | Submit feedback, Create/Delete ticket, Update status |
| **GroupProvider** | Study groups management | Groups list, group details | Create, Join, Leave, Delete groups |
| **MessagingProvider** | Chat/messaging state | Conversations, messages | Send, Read messages |
| **TeacherProvider** | Teacher-specific features | Subjects, assignments, attendance | CRUD for assignments, attendance |

---

## 5. Summary of Navigation & State Management Features

| Feature | Implementation |
|---|---|
| **Multi-Screen Navigation** | 25+ named routes in `AppRoutes`, centralized `AppRouter` |
| **Data Passing** | Route arguments (`PostModel`, `eventId`, `ticketId`), dynamic URL parsing |
| **Global User State** | `AuthProvider` with `ChangeNotifier` + Firebase auth stream |
| **CRUD State Updates** | `FeedProvider`, `EventProvider`, `ProfileProvider` with `notifyListeners()` |
| **Bottom Navigation Bar** | 5 tabs (Feed, Events, Groups, Messages, Profile) with animated transitions |
| **State Management Approach** | **Provider** – `MultiProvider`, `ChangeNotifierProvider`, `ChangeNotifierProxyProvider`, `Consumer`, `context.watch/read` |
| **Navigation Service** | Singleton with `GlobalKey<NavigatorState>` for context-independent navigation |
| **Auth Flow** | Splash → (authenticated ? Home : Login) with `pushReplacementNamed` |
| **Base Provider Pattern** | Shared `BaseProvider` class with loading/error/`executeOperation()` |

---

## 6. Expected Outcome

After completing this practical, the CampusConnect app has:

✅ **Centralized route management** – All 25+ routes defined in `AppRoutes` with `AppRouter`  
✅ **Data passing between screens** – PostModel, eventId, ticketId passed via route arguments  
✅ **Global user/session state** – `AuthProvider` tracks authenticated user across all screens  
✅ **CRUD state management** – Dedicated providers for posts, events, feedback, tickets, and groups  
✅ **Bottom Navigation Bar** – 5 animated tabs for primary navigation with FAB on Feed  
✅ **Provider as state management** – 7 providers registered with `MultiProvider` at the app root  
✅ **Context-independent navigation** – `NavigationService` singleton for navigation from providers/services  
✅ **Dependent provider wiring** – `FeedProvider` receives `AuthProvider` via `ChangeNotifierProxyProvider`  
✅ **Auth-based navigation flow** – Splash screen checks auth state and routes accordingly

---

## 7. Conclusion

This practical successfully implemented navigation and state management in the CampusConnect Flutter application. The app uses **Provider** as its state management solution, with 7 specialized providers managing different feature domains. The centralized `AppRouter` handles all navigation with support for named routes, route arguments, and dynamic URL parsing. The `BaseProvider` pattern ensures consistent loading/error handling across all providers, while the `MultiProvider` setup at the app root makes state accessible throughout the widget tree. The architecture supports seamless data flow between screens and predictable state updates for all CRUD operations.
