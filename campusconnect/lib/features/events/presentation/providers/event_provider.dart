import '../../../../core/base/base_provider.dart';
import '../../domain/models/event_model.dart';
import '../../data/services/event_service.dart';
import '../../../auth/domain/models/user_model.dart';

/// Event Provider
/// Manages event state and provides event methods to the UI
class EventProvider extends BaseProvider {
  final EventService _eventService = EventService();

  List<EventModel> _allEvents = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _attendingEvents = [];
  List<EventModel> _myEvents = [];
  EventModel? _selectedEvent;
  List<UserModel> _attendees = [];

  /// Getters
  List<EventModel> get allEvents => _allEvents;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get attendingEvents => _attendingEvents;
  List<EventModel> get myEvents => _myEvents;
  EventModel? get selectedEvent => _selectedEvent;
  List<UserModel> get attendees => _attendees;

  /// Load all events
  Future<void> loadAllEvents() async {
    await executeOperation(() async {
      _allEvents = await _eventService.getAllEvents();
      notifyListeners();
    });
  }

  /// Load upcoming events
  Future<void> loadUpcomingEvents() async {
    await executeOperation(() async {
      _upcomingEvents = await _eventService.getUpcomingEvents();
      notifyListeners();
    });
  }

  /// Load events user is attending
  Future<void> loadAttendingEvents(String userId) async {
    await executeOperation(() async {
      _attendingEvents = await _eventService.getAttendingEvents(userId);
      notifyListeners();
    });
  }

  /// Load events organized by user
  Future<void> loadMyEvents(String userId) async {
    await executeOperation(() async {
      _myEvents = await _eventService.getMyEvents(userId);
      notifyListeners();
    });
  }

  /// Load single event by ID
  Future<void> loadEvent(String eventId) async {
    await executeOperation(() async {
      _selectedEvent = await _eventService.getEventById(eventId);
      notifyListeners();
    });
  }

  /// Create new event
  Future<bool> createEvent(EventModel event) async {
    final result = await executeOperation(() async {
      final createdEvent = await _eventService.createEvent(event);

      // Add to local lists
      _allEvents.add(createdEvent);
      _myEvents.add(createdEvent);
      if (createdEvent.isUpcoming) {
        _upcomingEvents.add(createdEvent);
      }

      notifyListeners();
      return createdEvent;
    });
    return result != null;
  }

  /// Update event
  Future<bool> updateEvent(EventModel event) async {
    final result = await executeOperation(() async {
      await _eventService.updateEvent(event);

      // Update in local lists
      _updateEventInLists(event);

      if (_selectedEvent?.eventId == event.eventId) {
        _selectedEvent = event;
      }

      notifyListeners();
      return true;
    });
    return result ?? false;
  }

  /// Delete event
  Future<bool> deleteEvent(String eventId) async {
    final result = await executeOperation(() async {
      await _eventService.deleteEvent(eventId);

      // Remove from local lists
      _removeEventFromLists(eventId);

      if (_selectedEvent?.eventId == eventId) {
        _selectedEvent = null;
      }

      notifyListeners();
      return true;
    });
    return result ?? false;
  }

  /// Toggle attendance (join/leave event)
  Future<bool> toggleAttendance(String eventId, String userId) async {
    final result = await executeOperation(() async {
      await _eventService.toggleAttendance(eventId, userId);

      // Refresh the event to get updated attendance
      final updatedEvent = await _eventService.getEventById(eventId);
      if (updatedEvent != null) {
        _updateEventInLists(updatedEvent);

        // Update attending events list
        if (updatedEvent.isAttending(userId)) {
          if (!_attendingEvents.any((e) => e.eventId == eventId)) {
            _attendingEvents.add(updatedEvent);
          }
        } else {
          _attendingEvents.removeWhere((e) => e.eventId == eventId);
        }

        if (_selectedEvent?.eventId == eventId) {
          _selectedEvent = updatedEvent;
        }
      }

      notifyListeners();
      return true;
    });
    return result ?? false;
  }

  /// Load attendees for an event
  Future<void> loadAttendees(String eventId) async {
    await executeOperation(() async {
      _attendees = await _eventService.getAttendees(eventId);
      notifyListeners();
    });
  }

  /// Search events by title
  Future<List<EventModel>> searchEvents(String query) async {
    if (query.isEmpty) return _allEvents;

    return _allEvents
        .where((event) =>
            event.title.toLowerCase().contains(query.toLowerCase()) ||
            event.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Filter events by category
  List<EventModel> filterByCategory(String category) {
    if (category == 'All') return _allEvents;
    return _allEvents.where((event) => event.category == category).toList();
  }

  /// Helper method to update event in all lists
  void _updateEventInLists(EventModel event) {
    // Update in all events
    final allIndex = _allEvents.indexWhere((e) => e.eventId == event.eventId);
    if (allIndex != -1) {
      _allEvents[allIndex] = event;
    }

    // Update in upcoming events
    final upcomingIndex =
        _upcomingEvents.indexWhere((e) => e.eventId == event.eventId);
    if (upcomingIndex != -1) {
      if (event.isUpcoming) {
        _upcomingEvents[upcomingIndex] = event;
      } else {
        _upcomingEvents.removeAt(upcomingIndex);
      }
    } else if (event.isUpcoming) {
      _upcomingEvents.add(event);
    }

    // Update in my events
    final myIndex = _myEvents.indexWhere((e) => e.eventId == event.eventId);
    if (myIndex != -1) {
      _myEvents[myIndex] = event;
    }

    // Update in attending events (if user is attending)
    final attendingIndex =
        _attendingEvents.indexWhere((e) => e.eventId == event.eventId);
    if (attendingIndex != -1) {
      _attendingEvents[attendingIndex] = event;
    }
  }

  /// Helper method to remove event from all lists
  void _removeEventFromLists(String eventId) {
    _allEvents.removeWhere((e) => e.eventId == eventId);
    _upcomingEvents.removeWhere((e) => e.eventId == eventId);
    _myEvents.removeWhere((e) => e.eventId == eventId);
    _attendingEvents.removeWhere((e) => e.eventId == eventId);
  }

  /// Refresh all event lists
  Future<void> refreshEvents(String userId) async {
    await Future.wait([
      loadAllEvents(),
      loadUpcomingEvents(),
      loadAttendingEvents(userId),
      loadMyEvents(userId),
    ]);
  }

  /// Clear all data
  void clear() {
    _allEvents = [];
    _upcomingEvents = [];
    _attendingEvents = [];
    _myEvents = [];
    _selectedEvent = null;
    _attendees = [];
    notifyListeners();
  }
}
