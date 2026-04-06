import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';

/// Events Screen
/// Displays upcoming and past events with premium gradient tabs
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final eventProvider = context.read<EventProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid ?? '';

    await eventProvider.refreshEvents(userId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Events'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Attending'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar with premium styling
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: AppShadows.subtle,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllEventsTab(currentUserId),
                _buildUpcomingEventsTab(currentUserId),
                _buildAttendingEventsTab(currentUserId),
              ],
            ),
          ),
        ],
      ),
      // Only show FAB for admins and teachers
      floatingActionButton: _canCreateEvents(authProvider)
          ? Container(
              decoration: BoxDecoration(
                gradient: AppGradients.button,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: AppShadows.elevated,
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, '/events/create');
                },
                label: const Text('Create Event'),
                icon: const Icon(Icons.add),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            )
          : null,
    );
  }

  /// Check if user has permission to create events
  bool _canCreateEvents(AuthProvider authProvider) {
    final userRole = authProvider.currentUser?.role;
    return userRole == 'admin' || userRole == 'teacher';
  }

  Widget _buildAllEventsTab(String? currentUserId) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        if (eventProvider.isLoading) {
          return const LoadingWidget();
        }

        if (eventProvider.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  eventProvider.errorMessage,
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: _loadEvents,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final events = _searchQuery.isEmpty
            ? eventProvider.allEvents
            : eventProvider.allEvents
                .where((event) =>
                    event.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    event.description
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();

        if (events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_busy_rounded,
            message: _searchQuery.isEmpty
                ? 'No events available'
                : 'No events found',
          );
        }

        return RefreshIndicator(
          onRefresh: _loadEvents,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                currentUserId: currentUserId,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/events/${event.eventId}',
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingEventsTab(String? currentUserId) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        if (eventProvider.isLoading) {
          return const LoadingWidget();
        }

        final events = _searchQuery.isEmpty
            ? eventProvider.upcomingEvents
            : eventProvider.upcomingEvents
                .where((event) =>
                    event.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    event.description
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();

        if (events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_available_rounded,
            message: _searchQuery.isEmpty
                ? 'No upcoming events'
                : 'No upcoming events found',
          );
        }

        return RefreshIndicator(
          onRefresh: _loadEvents,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                currentUserId: currentUserId,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/events/${event.eventId}',
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAttendingEventsTab(String? currentUserId) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        if (eventProvider.isLoading) {
          return const LoadingWidget();
        }

        final events = _searchQuery.isEmpty
            ? eventProvider.attendingEvents
            : eventProvider.attendingEvents
                .where((event) =>
                    event.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    event.description
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();

        if (events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_note_rounded,
            message: _searchQuery.isEmpty
                ? 'You\'re not attending any events'
                : 'No attending events found',
            subtitle:
                _searchQuery.isEmpty ? 'Join events to see them here' : null,
          );
        }

        return RefreshIndicator(
          onRefresh: _loadEvents,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                currentUserId: currentUserId,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/events/${event.eventId}',
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
