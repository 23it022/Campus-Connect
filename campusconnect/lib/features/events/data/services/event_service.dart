import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/event_model.dart';
import '../../../auth/domain/models/user_model.dart';

/// Event Service
/// Handles all Firebase operations for events
class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _eventsCollection = 'events';

  /// Get all events ordered by date
  Future<List<EventModel>> getAllEvents() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .orderBy('eventDate', descending: false)
          .get();

      return snapshot.docs.map((doc) => EventModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  /// Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_eventsCollection).doc(eventId).get();

      if (!doc.exists) return null;

      return EventModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  /// Get upcoming events (future events)
  Future<List<EventModel>> getUpcomingEvents() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('eventDate', descending: false)
          .get();

      return snapshot.docs.map((doc) => EventModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming events: $e');
    }
  }

  /// Get past events
  Future<List<EventModel>> getPastEvents() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('eventDate', isLessThan: Timestamp.now())
          .orderBy('eventDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => EventModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get past events: $e');
    }
  }

  /// Get events organized by a specific user
  Future<List<EventModel>> getMyEvents(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('organizerId', isEqualTo: userId)
          .orderBy('eventDate', descending: false)
          .get();

      return snapshot.docs.map((doc) => EventModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get my events: $e');
    }
  }

  /// Get events user is attending
  Future<List<EventModel>> getAttendingEvents(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('attendees', arrayContains: userId)
          .orderBy('eventDate', descending: false)
          .get();

      return snapshot.docs.map((doc) => EventModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get attending events: $e');
    }
  }

  /// Create new event
  Future<EventModel> createEvent(EventModel event) async {
    try {
      final docRef = _firestore.collection(_eventsCollection).doc();
      final eventWithId = event.copyWith(eventId: docRef.id);

      await docRef.set(eventWithId.toMap());

      return eventWithId;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  /// Update existing event
  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection(_eventsCollection)
          .doc(event.eventId)
          .update(event.toMap());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_eventsCollection).doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  /// Toggle user attendance (join/leave event)
  Future<void> toggleAttendance(String eventId, String userId) async {
    try {
      final docRef = _firestore.collection(_eventsCollection).doc(eventId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Event not found');
        }

        final event = EventModel.fromDocument(snapshot);
        final isAttending = event.isAttending(userId);

        if (isAttending) {
          // Remove user from attendees
          transaction.update(docRef, {
            'attendees': FieldValue.arrayRemove([userId]),
            'attendeesCount': FieldValue.increment(-1),
          });
        } else {
          // Check if event is full
          if (event.isFull) {
            throw Exception('Event is full');
          }

          // Add user to attendees
          transaction.update(docRef, {
            'attendees': FieldValue.arrayUnion([userId]),
            'attendeesCount': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to toggle attendance: $e');
    }
  }

  /// Get attendee user profiles
  Future<List<UserModel>> getAttendees(String eventId) async {
    try {
      final event = await getEventById(eventId);
      if (event == null || event.attendees.isEmpty) {
        return [];
      }

      // Get user profiles for all attendees
      final List<UserModel> attendees = [];
      for (final userId in event.attendees) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          attendees.add(UserModel.fromDocument(userDoc));
        }
      }

      return attendees;
    } catch (e) {
      throw Exception('Failed to get attendees: $e');
    }
  }

  /// Search events by title
  Stream<List<EventModel>> searchEvents(String query) {
    try {
      return _firestore
          .collection(_eventsCollection)
          .orderBy('title')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => EventModel.fromDocument(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  /// Get events stream for real-time updates
  Stream<List<EventModel>> getEventsStream() {
    try {
      return _firestore
          .collection(_eventsCollection)
          .orderBy('eventDate', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => EventModel.fromDocument(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get events stream: $e');
    }
  }
}
