# LAB 7 – Implementation of UI Components & User Controls

**Project Name:** CampusConnect – Student Social Media App  
**Technology:** Flutter (Dart) with Firebase  
**Framework:** Material 3 (Material Design 3) with Google Fonts (Poppins)

---

## 1. Introduction

User Interface (UI) is essential for creating effective, user-friendly, and visually appealing mobile applications. In this practical, we implemented a comprehensive set of UI components and interactive controls across the **CampusConnect** application, including:

- Functional forms with validation (Login, Signup, Create Post, Create Event)
- Dynamic data display using ListView and Card layouts (Feed, Events, Groups)
- Interactive components (buttons, switches, dropdowns, filter chips)
- Dialogs, alerts, and snackbars for user feedback
- Premium theming and styling using a centralized design system
- Bottom Navigation Bar with animated tabs and a Floating Action Button (FAB)

The app's UI structure is organized across **36 screens** within **17 feature modules**, each connected to reusable shared widgets and a consistent design system.

---

## 2. Practical Objectives

By completing this practical, we achieved the following:

- **Used standard UI components** – TextFields, Buttons, Cards, ListViews, Switches, RadioButtons, Chips, Dialogs, and Snackbars
- **Built clean and responsive screen layouts** – Using `SingleChildScrollView`, `CustomScrollView`, `SliverAppBar`, and `Column`/`Row` based layouts
- **Displayed dynamic data** – Using `ListView.builder` with `PostCard`, `EventCard`, and `GroupCard` widgets
- **Implemented navigation components** – Bottom Navigation Bar (5 tabs) with animated transitions and a Floating Action Button
- **Used alerts, dialogs, and snackbars** – For delete confirmation, success/error messages, and settings changes
- **Enhanced usability** – With consistent spacing, alignment, gradients, rounded corners, and typography from a centralized design system

---

## 3. Step-by-Step Implementation

### STEP 1: Screens and Their UI Components

The following table maps each screen to its UI components:

| Screen | UI Components Used |
|---|---|
| **Login Screen** | TextFields, Gradient Button, Password Toggle, Validation, SnackBar, Animated Form Card |
| **Signup Screen** | TextFields, Gradient Button, Validation, SnackBar |
| **Forgot Password Screen** | TextField (email), Button, SnackBar |
| **Home Screen** | Bottom Navigation Bar (5 tabs), FAB |
| **Feed Screen** | Gradient AppBar, Search TextField, Filter Chips, ListView.builder, PostCard, AlertDialog, SnackBar |
| **Create Post Screen** | TextFields, Image Picker, Button, Validation |
| **Events Screen** | ListView, Event Cards, FAB |
| **Create Event Screen** | TextFields, Date Picker, Time Picker, Image Picker, Dropdown, Button |
| **Groups Screen** | ListView, Group Cards |
| **Profile Screen** | Avatar, Info Chips, Premium Menu Cards with Gradients |
| **Settings Screen** | SwitchListTile (toggles), RadioListTile (radio buttons), AlertDialog, SnackBar |
| **Teacher Dashboard** | Stats Cards, Quick Action Buttons, Recent Activity List |

---

### STEP 2: Building Forms Using Input Components

#### Custom Text Field Widget (`custom_text_field.dart`)

We created a reusable `CustomTextField` widget with the following features:

- **Labels and hints** for every input field
- **Prefix icons** for visual clarity (email icon, lock icon, etc.)
- **Suffix widgets** for additional controls (password visibility toggle)
- **Form validation** with error messages displayed below fields
- **Animated focus state** with shadow that appears on focus
- **Keyboard type** support (email, text, number)

```dart
class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  // ...
}
```

#### Login Screen Form Implementation

The Login Screen uses `Form` with `GlobalKey<FormState>` for validation:

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      // Email Field with validation
      CustomTextField(
        label: 'Email',
        hint: 'Enter your email',
        controller: _emailController,
        prefixIcon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),

      // Password Field with visibility toggle
      CustomTextField(
        label: 'Password',
        hint: 'Enter your password',
        controller: _passwordController,
        obscureText: _obscurePassword,
        prefixIcon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 7) {
            return 'Password must be greater than 6 characters';
          }
          return null;
        },
      ),
    ],
  ),
)
```

#### Create Event Screen – Date Picker & Time Picker

```dart
// Date Picker
Future<void> _selectDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (picked != null) {
    setState(() => _selectedDate = picked);
  }
}

// Time Picker
Future<void> _selectTime() async {
  final picked = await showTimePicker(
    context: context,
    initialTime: _selectedTime ?? TimeOfDay.now(),
  );
  if (picked != null) {
    setState(() => _selectedTime = picked);
  }
}
```

#### Settings Screen – Toggle Switches & Radio Buttons

```dart
// Toggle Switch using SwitchListTile
SwitchListTile(
  title: Text('Push Notifications'),
  subtitle: Text('Receive push notifications on this device'),
  value: _pushNotificationsEnabled,
  onChanged: (value) => setState(() => _pushNotificationsEnabled = value),
  activeColor: AppColors.primary,
),

// Radio Buttons using RadioListTile (Language Selection)
RadioListTile<String>(
  title: Text(lang),
  value: lang,
  groupValue: _language,
  onChanged: (value) {
    setState(() => _language = value!);
    Navigator.pop(context);
  },
),
```

---

### STEP 3: Buttons & Action Components

#### Custom Button Widget (`custom_button.dart`)

A reusable gradient button with:

- **Gradient background** using `AppGradients.button`
- **Loading state** with `CircularProgressIndicator`
- **Press animation** using `AnimatedScale`
- **Outlined variant** for secondary actions

```dart
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  // ...
}
```

**Usage in Login Screen:**

```dart
Consumer<AuthProvider>(
  builder: (context, auth, _) => CustomButton(
    text: 'Login',
    onPressed: _handleLogin,
    isLoading: auth.isLoading,
  ),
),
```

#### Floating Action Button (FAB)

Used on the Feed Screen to create new posts:

```dart
floatingActionButton: Container(
  decoration: BoxDecoration(
    gradient: AppGradients.button,
    shape: BoxShape.circle,
    boxShadow: AppShadows.elevated,
  ),
  child: FloatingActionButton(
    onPressed: () => Navigator.pushNamed(context, '/create-post'),
    backgroundColor: Colors.transparent,
    elevation: 0,
    child: const Icon(Icons.add, color: AppColors.white),
  ),
),
```

#### Icon Buttons in AppBar

```dart
actions: [
  IconButton(
    icon: const Icon(Icons.bookmark_outline_rounded),
    onPressed: () => Navigator.pushNamed(context, '/bookmarks'),
    tooltip: 'Bookmarks',
  ),
  IconButton(
    icon: const Icon(Icons.notifications_outlined),
    onPressed: () { /* Navigate to notifications */ },
  ),
],
```

---

### STEP 4: List & Card Views

#### ListView.builder for Feed Posts

Dynamic list rendering using `ListView.builder` with `PostCard` widget:

```dart
ListView.builder(
  controller: _scrollController,
  itemCount: feedProvider.posts.length,
  itemBuilder: (context, index) {
    final post = feedProvider.posts[index];
    return PostCard(
      post: post,
      onReactionTap: () { /* Reaction logic */ },
      onComment: () { /* Navigate to post detail */ },
      onBookmark: () { feedProvider.toggleBookmark(post); },
      onShare: () { /* Share dialog */ },
      onDelete: () { /* Delete confirmation dialog */ },
      onEdit: () { /* Navigate to edit screen */ },
    );
  },
),
```

#### Filter Chips Widget

Used for filtering feed posts by category:

```dart
FilterChipsWidget(
  currentFilter: feedProvider.currentFilter,
  onFilterChanged: (filter) => feedProvider.setFilter(filter),
),
```

#### Teacher Dashboard – Stats Cards

```dart
// Stats cards with dynamic data
Widget _buildStatsCards(TeacherProvider provider) {
  // Displays cards with subject count, assignment count, etc.
  // Each card has an icon, title, value, and color gradient
}
```

#### Profile Screen – Premium Menu Cards

```dart
Widget _buildPremiumMenuCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required Gradient gradient,
  required VoidCallback onTap,
}) {
  // Card with gradient icon background, title, subtitle, and tap action
}
```

---

### STEP 5: Navigation UI Elements

#### Bottom Navigation Bar (Home Screen)

The `HomeScreen` implements a custom animated Bottom Navigation Bar with 5 tabs:

```dart
// 5 Navigation Tabs
final List<String> _labels = ['Feed', 'Events', 'Groups', 'Messages', 'Profile'];

// Animated bottom nav bar with gradient active tab
Row(
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
                style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }),
),
```

#### Gradient Top AppBar

Used across all major screens (Feed, Events, Groups):

```dart
AppBar(
  title: const Text('CampusConnect'),
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: AppGradients.primary,
    ),
  ),
  actions: [
    IconButton(icon: const Icon(Icons.bookmark_outline_rounded), onPressed: () {}),
    IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
  ],
),
```

#### SliverAppBar (Settings Screen)

```dart
SliverAppBar(
  expandedHeight: 160,
  pinned: true,
  flexibleSpace: FlexibleSpaceBar(
    title: const Text('Settings'),
    background: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA), Color(0xFFAB47BC)],
        ),
      ),
    ),
  ),
),
```

---

### STEP 6: Alerts, Dialogs & Snackbars

#### Delete Confirmation Dialog

```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Delete Post'),
    content: const Text('Are you sure you want to delete this post?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Delete'),
      ),
    ],
  ),
);
```

#### Delete Account Dialog (with Warning Icon)

```dart
AlertDialog(
  title: const Row(
    children: [
      Icon(Icons.warning, color: AppColors.error),
      SizedBox(width: 8),
      Text('Delete Account'),
    ],
  ),
  content: const Text(
    'Are you sure you want to delete your account? This action cannot be undone.',
  ),
  actions: [
    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
    ElevatedButton(
      onPressed: () { /* Delete logic */ },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      child: const Text('Delete'),
    ),
  ],
),
```

#### Success & Error Snackbars

```dart
// Success Snackbar
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Login successful!'),
    backgroundColor: AppColors.success,
  ),
);

// Error Snackbar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(authProvider.errorMessage),
    backgroundColor: AppColors.error,
  ),
);

// Info Snackbar
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Settings saved'),
    duration: Duration(seconds: 1),
  ),
);
```

#### Change Password Dialog (Form inside Dialog)

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Change Password'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: currentPasswordController,
          decoration: const InputDecoration(labelText: 'Current Password'),
          obscureText: true,
        ),
        TextField(
          controller: newPasswordController,
          decoration: const InputDecoration(labelText: 'New Password'),
          obscureText: true,
        ),
        TextField(
          controller: confirmPasswordController,
          decoration: const InputDecoration(labelText: 'Confirm Password'),
          obscureText: true,
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ElevatedButton(onPressed: () { /* Validation & submit */ }, child: const Text('Change')),
    ],
  ),
);
```

---

### STEP 7: Basic UI Styling (Design System)

#### Color Palette (`constants.dart` – `AppColors`)

```dart
class AppColors {
  static const Color primary = Color(0xFF6C63FF);       // Purple
  static const Color primaryDark = Color(0xFF5848E8);
  static const Color primaryLight = Color(0xFF8B84FF);
  static const Color secondary = Color(0xFFFF6584);      // Pink
  static const Color success = Color(0xFF4CAF50);         // Green
  static const Color error = Color(0xFFF44336);           // Red
  static const Color warning = Color(0xFFFF9800);         // Orange
  static const Color background = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}
```

#### Typography (`AppTextStyles`)

```dart
class AppTextStyles {
  static const TextStyle h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const TextStyle h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle h3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const TextStyle body1 = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const TextStyle body2 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static const TextStyle caption = TextStyle(fontSize: 12);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
}
```

#### Spacing & Border Radius (`AppSpacing`)

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
}
```

#### Gradients (`AppGradients`)

```dart
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
  );
  static const LinearGradient button = LinearGradient(
    colors: [AppColors.primaryLight, AppColors.primary],
  );
}
```

#### Box Shadows (`AppShadows`)

```dart
class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> get elevated => [
    BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 16, offset: Offset(0, 6)),
  ];
}
```

#### Theme Configuration (`themes.dart`)

The app uses a centralized theme with Material 3 enabled:

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(),
      // AppBar, Card, Input, Button, FAB, Snackbar themes configured
    );
  }
}
```

---

## 4. Summary of UI Components Implemented

| Component Category | Components Used |
|---|---|
| **Forms & Inputs** | CustomTextField, TextFormField, TextField, Password Toggle, Date Picker, Time Picker, Image Picker |
| **Buttons** | CustomButton (Gradient + Outlined), ElevatedButton, TextButton, IconButton, FloatingActionButton |
| **Lists** | ListView.builder (Feed posts, Events, Groups, Chat list, Assignments) |
| **Cards** | PostCard, EventCard, GroupCard, Stats Card, Premium Menu Card |
| **Navigation** | Bottom Navigation Bar (5 tabs, animated), Top AppBar (gradient), SliverAppBar |
| **Interactive Controls** | SwitchListTile (toggles), RadioListTile, FilterChipsWidget, Chip |
| **Feedback** | AlertDialog (delete, change password, delete account), SnackBar (success, error, info) |
| **Animations** | AnimatedContainer, AnimatedScale, FadeTransition, SlideTransition, CurvedAnimation |
| **Styling** | AppColors, AppTextStyles, AppSpacing, AppGradients, AppShadows, Google Fonts (Poppins) |

---

## 5. Expected Outcome

After completing this practical, the CampusConnect app has:

✅ **Clean, structured, and interactive UI** across all 36 screens  
✅ **Functioning forms** with validation on Login, Signup, Create Post, and Create Event screens  
✅ **Dynamic lists and cards** displaying posts, events, groups, and messages  
✅ **Alerts and dialogs** for delete confirmations, password changes, and account management  
✅ **Snackbars** for success, error, and informational feedback  
✅ **Navigation controls** – Bottom Navigation Bar (5 tabs) with animated transitions and FAB  
✅ **Toggle switches and radio buttons** for settings preferences  
✅ **Consistent design system** – centralized colors, typography, spacing, gradients, and shadows  
✅ **Ready UI structure** for integration with CRUD & API operations in upcoming labs

---

## 6. Conclusion

This practical successfully implemented essential UI components and user controls in the CampusConnect Flutter application. The app now features a comprehensive, cohesive, and interactive interface built with Material 3 design principles, reusable widgets, and a centralized design system. The UI is fully prepared for navigation (Lab 8), API integration (Lab 9), and advanced module development (Lab 11).
