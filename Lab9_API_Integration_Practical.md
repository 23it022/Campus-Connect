# LAB 9 – REST API Integration

**Project Name:** CampusConnect – Student Social Media App  
**Technology:** Flutter (Dart) with Firebase  
**API Used:** Universities API (`http://universities.hipolabs.com/search`) – Free, No Auth Required  
**HTTP Package:** `http: ^1.2.0`

---

## 1. Introduction

REST APIs enable mobile applications to communicate with remote servers and retrieve live data. In this practical, we integrated an external REST API into the **CampusConnect** application to fetch and display university data from around the world.

We implemented:

- **HTTP GET requests** using the `http` package
- **JSON response parsing** with model classes and `fromJson()` factory constructors
- **Data display** in premium card-based ListView with search and filter
- **Loading states** using shimmer effects
- **Error handling** with retry functionality
- **Data passing** from list screen to detail screen via route arguments
- **Provider-based state management** for API data with `ExploreProvider`

---

## 2. Practical Objectives

By completing this practical, we achieved the following:

- **Understood REST APIs** – Used a public REST API with GET endpoints and query parameters
- **Performed GET requests** – HTTP calls via `http.get()` with timeout and error handling
- **Parsed JSON responses** – `json.decode()` to parse API response, `fromJson()` factory for model mapping
- **Displayed API data** – `ListView.builder` with university cards, search bar, and country filter chips
- **Implemented loading and error states** – Shimmer loading placeholders, error message with retry button, empty state

---

## 3. Step-by-Step Implementation

### STEP 1: Adding the HTTP Package

**File:** `pubspec.yaml`

```yaml
dependencies:
  # HTTP client for REST API calls
  http: ^1.2.0
```

After adding, run:

```bash
flutter pub get
```

---

### STEP 2: Understanding the REST API

**API:** Universities API  
**Base URL:** `http://universities.hipolabs.com/search`  
**Method:** GET (no authentication required)

| Endpoint | Description | Example |
|---|---|---|
| `?country=India` | Fetch universities by country | `/search?country=India` |
| `?name=Delhi` | Search by university name | `/search?name=Delhi` |
| `?name=Delhi&country=India` | Combined search | `/search?name=Delhi&country=India` |

**Sample JSON Response:**

```json
[
  {
    "name": "Indian Institute of Technology Delhi",
    "country": "India",
    "alpha_two_code": "IN",
    "state-province": "New Delhi",
    "domains": ["iitd.ac.in"],
    "web_pages": ["http://www.iitd.ac.in/"]
  }
]
```

---

### STEP 3: Creating the Data Model (`UniversityModel`)

**File:** `lib/features/explore/domain/models/university_model.dart`

The model class parses JSON from the API response using a `fromJson()` factory constructor:

```dart
class UniversityModel {
  final String name;
  final String country;
  final String alphaTwoCode;
  final String? stateProvince;
  final List<String> domains;
  final List<String> webPages;

  UniversityModel({
    required this.name,
    required this.country,
    required this.alphaTwoCode,
    this.stateProvince,
    required this.domains,
    required this.webPages,
  });

  /// Factory constructor to parse JSON from API response
  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      alphaTwoCode: json['alpha_two_code'] ?? '',
      stateProvince: json['state-province'],
      domains: List<String>.from(json['domains'] ?? []),
      webPages: List<String>.from(json['web_pages'] ?? []),
    );
  }

  /// Convert model back to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'alpha_two_code': alphaTwoCode,
      'state-province': stateProvince,
      'domains': domains,
      'web_pages': webPages,
    };
  }

  String get primaryWebsite => webPages.isNotEmpty ? webPages.first : '';
  String get primaryDomain => domains.isNotEmpty ? domains.first : '';
}
```

---

### STEP 4: Creating the API Service (HTTP GET Requests)

**File:** `lib/features/explore/data/services/university_api_service.dart`

The service class handles all HTTP communication:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class UniversityApiService {
  static const String _baseUrl = 'http://universities.hipolabs.com/search';
  static const Duration _timeout = Duration(seconds: 15);

  /// Fetch universities by country – HTTP GET request
  Future<List<UniversityModel>> fetchUniversitiesByCountry(String country) async {
    try {
      // Step 1: Build the URL with query parameters
      final uri = Uri.parse('$_baseUrl?country=$country');

      // Step 2: Perform HTTP GET request with timeout
      final response = await http.get(uri).timeout(_timeout);

      // Step 3: Check response status code
      if (response.statusCode == 200) {
        // Step 4: Parse JSON response body
        final List<dynamic> jsonList = json.decode(response.body);

        // Step 5: Map each JSON object to UniversityModel
        return jsonList
            .map((json) => UniversityModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Check your connection.');
      }
      throw Exception('Failed to fetch universities: $e');
    }
  }

  /// Search universities by name and country
  Future<List<UniversityModel>> searchUniversities({
    required String name,
    String? country,
  }) async {
    String url = '$_baseUrl?name=$name';
    if (country != null && country.isNotEmpty) {
      url += '&country=$country';
    }

    final uri = Uri.parse(url);
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => UniversityModel.fromJson(json)).toList();
    } else {
      throw Exception('Search failed. Status: ${response.statusCode}');
    }
  }
}
```

**Key Concepts Demonstrated:**

| Concept | Implementation |
|---|---|
| **HTTP GET Request** | `http.get(uri)` |
| **Query Parameters** | URL construction: `?country=India&name=Delhi` |
| **JSON Parsing** | `json.decode(response.body)` returns `List<dynamic>` |
| **Model Mapping** | `.map((json) => UniversityModel.fromJson(json))` |
| **Status Code Check** | `response.statusCode == 200` |
| **Timeout Handling** | `.timeout(Duration(seconds: 15))` |
| **Error Handling** | `try-catch` with meaningful error messages |

---

### STEP 5: State Management with ExploreProvider

**File:** `lib/features/explore/presentation/providers/explore_provider.dart`

The provider manages API data state, extending `BaseProvider` for consistent loading/error handling:

```dart
class ExploreProvider extends BaseProvider {
  final UniversityApiService _apiService = UniversityApiService();

  List<UniversityModel> _universities = [];
  String _selectedCountry = 'India';
  String _searchQuery = '';

  List<UniversityModel> get universities => ...;
  String get selectedCountry => _selectedCountry;

  /// Load universities from API
  Future<void> loadUniversities() async {
    await executeOperation(() async {
      _universities = await _apiService.fetchUniversitiesByCountry(_selectedCountry);
      notifyListeners();
    });
  }

  /// Search universities (local filter + API fallback)
  Future<void> searchUniversities(String query) async {
    _searchQuery = query;
    // Local filter first for speed
    _filteredUniversities = _universities
        .where((uni) => uni.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();

    // API search for broader results
    if (_filteredUniversities.isEmpty && query.length >= 3) {
      await executeOperation(() async {
        _filteredUniversities = await _apiService.searchUniversities(
          name: query, country: _selectedCountry,
        );
        notifyListeners();
      });
    }
  }

  /// Change country and reload
  Future<void> setCountry(String country) async {
    _selectedCountry = country;
    await loadUniversities();
  }
}
```

**Provider Registration in `main.dart`:**

```dart
MultiProvider(
  providers: [
    // ... existing providers ...

    // Explore Provider – manages API data
    ChangeNotifierProvider(
      create: (_) => ExploreProvider(),
    ),
  ],
  child: MaterialApp(/* ... */),
)
```

---

### STEP 6: Displaying API Data (ExploreScreen)

**File:** `lib/features/explore/presentation/screens/explore_screen.dart`

The screen displays data in three states: **Loading**, **Error**, and **Success**.

#### Loading State (Shimmer)

```dart
if (provider.isLoading) {
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) => const _ShimmerUniversityCard(),
      childCount: 6,
    ),
  );
}
```

#### Error State (with Retry)

```dart
if (provider.errorMessage.isNotEmpty) {
  return SliverFillRemaining(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64),
          Text('Failed to load universities'),
          Text(provider.errorMessage),
          ElevatedButton.icon(
            onPressed: () => provider.loadUniversities(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
```

#### Success State (University Cards)

```dart
return SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) {
      final university = provider.universities[index];
      return _UniversityCard(
        university: university,
        onTap: () {
          // Pass data to detail screen via route arguments
          Navigator.pushNamed(
            context,
            '/university-detail',
            arguments: university,  // Passing UniversityModel object
          );
        },
      );
    },
    childCount: provider.universities.length,
  ),
);
```

#### Search Bar & Country Filter Chips

```dart
// Search Bar
TextField(
  controller: _searchController,
  decoration: InputDecoration(hintText: 'Search universities...'),
  onChanged: (value) {
    context.read<ExploreProvider>().searchUniversities(value);
  },
),

// Country Filter Chips
FilterChip(
  label: Text(country),
  selected: provider.selectedCountry == country,
  onSelected: (_) => provider.setCountry(country),
),
```

---

### STEP 7: Data Passing to Detail Screen

**File:** `lib/features/explore/presentation/screens/university_detail_screen.dart`

Data is passed via `Navigator.pushNamed()` arguments and received in `generateRoute()`:

```dart
// Sender: ExploreScreen
Navigator.pushNamed(
  context,
  '/university-detail',
  arguments: university,  // UniversityModel passed as argument
);

// Receiver: AppRouter.generateRoute()
if (settings.name == AppRoutes.universityDetail) {
  final university = settings.arguments as UniversityModel?;
  if (university == null) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text('University not found'))),
    );
  }
  return MaterialPageRoute(
    builder: (_) => UniversityDetailScreen(university: university),
  );
}
```

The detail screen displays full university info with sections for Location, Domains, and Websites, plus a "Visit Website" button using `url_launcher`.

---

### STEP 8: Navigation Integration

**Bottom Navigation Bar** updated to include the new **Explore** tab:

```dart
// HomeScreen – 6 tabs now
final List<Widget> _screens = [
  const FeedScreen(),
  const EventsScreen(),
  const GroupsScreen(),
  const ExploreScreen(),    // New API-powered tab
  const ChatListScreen(),
  const ProfileScreen(),
];

final List<String> _labels = [
  'Feed', 'Events', 'Groups', 'Explore', 'Messages', 'Profile',
];
```

**Routes added to `AppRouter`:**

```dart
AppRoutes.explore: (context) => const ExploreScreen(),
// University detail handled in generateRoute() with argument passing
```

---

## 4. Summary of API Integration

| Component | File | Purpose |
|---|---|---|
| **HTTP Package** | `pubspec.yaml` | `http: ^1.2.0` for making HTTP requests |
| **Data Model** | `university_model.dart` | Parses JSON with `fromJson()` factory |
| **API Service** | `university_api_service.dart` | GET requests, JSON parsing, error handling |
| **Provider** | `explore_provider.dart` | State management for API data |
| **List Screen** | `explore_screen.dart` | Search, filter chips, shimmer, error, card list |
| **Detail Screen** | `university_detail_screen.dart` | Data passed via route arguments |
| **Routes** | `app_router.dart` | `/explore`, `/university-detail` |
| **Navigation** | `home_screen.dart` | Explore tab in bottom nav bar |

---

## 5. API Request/Response Flow

```
User taps "Explore" tab
        ↓
ExploreProvider.loadUniversities()
        ↓
UniversityApiService.fetchUniversitiesByCountry("India")
        ↓
HTTP GET → http://universities.hipolabs.com/search?country=India
        ↓
Response: 200 OK → JSON Array
        ↓
json.decode(response.body) → List<dynamic>
        ↓
.map((json) => UniversityModel.fromJson(json)) → List<UniversityModel>
        ↓
Provider: _universities = result → notifyListeners()
        ↓
UI rebuilds with Consumer<ExploreProvider>
        ↓
ListView.builder → UniversityCard widgets
```

---

## 6. Expected Outcome

After completing this practical, the CampusConnect app has:

✅ **HTTP GET requests** to a public REST API using the `http` package  
✅ **JSON parsing** with `json.decode()` and `fromJson()` factory constructors  
✅ **Data display** in cards via `ListView.builder` with search and filter  
✅ **Loading states** using shimmer effect placeholders  
✅ **Error handling** with error message display and retry button  
✅ **Data passing** between Explore list and University detail screen via route arguments  
✅ **State management** for API data using `ExploreProvider` extending `BaseProvider`  
✅ **Navigation integration** with new Explore tab in the bottom navigation bar

---

## 7. Conclusion

This practical successfully integrated an external REST API into the CampusConnect Flutter application. The Explore Universities feature demonstrates the complete API integration workflow: making HTTP GET requests with the `http` package, parsing JSON responses into Dart model objects, managing API data state with Provider, and displaying the data in a user-friendly interface with loading and error handling. The feature is seamlessly integrated into the existing app navigation with a dedicated tab in the bottom navigation bar.
