import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/attendee_list.dart';

///Event Detail Screen
/// Displays detailed information about an event
class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isLoadingAttendance = false;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    final eventProvider = context.read<EventProvider>();
    await eventProvider.loadEvent(widget.eventId);
    await eventProvider.loadAttendees(widget.eventId);
  }

  Future<void> _toggleAttendance() async {
    final authProvider = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId == null) return;

    setState(() => _isLoadingAttendance = true);

    final success =
        await eventProvider.toggleAttendance(widget.eventId, userId);

    setState(() => _isLoadingAttendance = false);

    if (mounted) {
      if (success) {
        final event = eventProvider.selectedEvent;
        final isAttending = event?.isAttending(userId) ?? false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAttending
                  ? 'You are now attending this event'
                  : 'You have left this event',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventProvider.errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final eventProvider = context.read<EventProvider>();
      final success = await eventProvider.deleteEvent(widget.eventId);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(eventProvider.errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// Check if user can edit this event
  /// Admins can edit any event, organizers and teachers can edit their own events
  bool _canEditEvent(String eventOrganizerId, AuthProvider authProvider) {
    final currentUserId = authProvider.currentUser?.uid;
    final userRole = authProvider.currentUser?.role;

    if (currentUserId == null) return false;

    // Admin can edit any event
    if (userRole == 'admin') return true;

    // Organizer can edit their own event (teachers and admins who created it)
    if (currentUserId == eventOrganizerId &&
        (userRole == 'teacher' || userRole == 'admin')) {
      return true;
    }

    return false;
  }

  /// Check if user can delete this event
  /// Admins can delete any event, organizers can delete their own events
  bool _canDeleteEvent(String eventOrganizerId, AuthProvider authProvider) {
    final currentUserId = authProvider.currentUser?.uid;
    final userRole = authProvider.currentUser?.role;

    if (currentUserId == null) return false;

    // Admin can delete any event
    if (userRole == 'admin') return true;

    // Organizer can delete their own event (teachers and admins who created it)
    if (currentUserId == eventOrganizerId &&
        (userRole == 'teacher' || userRole == 'admin')) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading && eventProvider.selectedEvent == null) {
            return const LoadingWidget();
          }

          final event = eventProvider.selectedEvent;
          if (event == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_busy,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Event not found',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final isOrganizer = currentUserId == event.organizerId;
          final isAttending =
              currentUserId != null && event.isAttending(currentUserId);
          final dateFormatter = DateFormat('EEEE, MMMM dd, yyyy');
          final timeFormatter = DateFormat('hh:mm a');

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: event.imageUrl.isNotEmpty
                      ? Image.network(
                          event.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
                actions: [
                  // Only show edit/delete for authorized users
                  if (_canEditEvent(event.organizerId, authProvider)) ...[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/events/edit/${event.eventId}',
                        );
                      },
                    ),
                  ],
                  if (_canDeleteEvent(event.organizerId, authProvider)) ...[
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _deleteEvent,
                    ),
                  ],
                ],
              ),

              // Event Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Category
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: AppTextStyles.h2,
                            ),
                          ),
                          _buildCategoryBadge(event.category),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Date and Time
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Date',
                        dateFormatter.format(event.eventDate),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      _buildInfoRow(
                        Icons.access_time,
                        'Time',
                        timeFormatter.format(event.eventDate),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Location
                      _buildInfoRow(
                        Icons.location_on,
                        'Location',
                        event.location,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Organizer
                      _buildInfoRow(
                        Icons.person,
                        'Organizer',
                        event.organizer,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Description
                      const Text(
                        'Description',
                        style: AppTextStyles.h3,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Text(
                        event.description,
                        style: AppTextStyles.body1,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Attendees Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Attendees (${event.attendeesCount}${event.maxAttendees != null ? '/${event.maxAttendees}' : ''})',
                            style: AppTextStyles.h3,
                          ),
                          if (event.isFull)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs / 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              child: const Text(
                                'Event Full',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      AttendeeList(
                        attendees: eventProvider.attendees,
                        totalCount: event.attendeesCount,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Attend/Leave Button (if not organizer)
                      if (!isOrganizer && currentUserId != null)
                        CustomButton(
                          text: isAttending ? 'Leave Event' : 'Attend Event',
                          onPressed: (event.isFull && !isAttending)
                              ? null
                              : _toggleAttendance,
                          isLoading: _isLoadingAttendance,
                        ),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.event,
          size: 100,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.body1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(String category) {
    final color = _getCategoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Academic':
        return const Color(0xFF2196F3);
      case 'Social':
        return const Color(0xFFE91E63);
      case 'Sports':
        return const Color(0xFF4CAF50);
      case 'Cultural':
        return const Color(0xFF9C27B0);
      case 'Other':
      default:
        return AppColors.textSecondary;
    }
  }
}
