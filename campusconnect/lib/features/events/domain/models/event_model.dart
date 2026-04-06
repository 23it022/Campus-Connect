import 'package:cloud_firestore/cloud_firestore.dart';

/// Event Model
/// Represents a campus event

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final DateTime eventDate;
  final String organizer;
  final String organizerId;
  final List<String> attendees;
  final int attendeesCount;
  final String category;
  final int? maxAttendees;
  final DateTime createdAt;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    this.imageUrl = '',
    required this.location,
    required this.eventDate,
    required this.organizer,
    required this.organizerId,
    List<String>? attendees,
    this.attendeesCount = 0,
    this.category = 'Other',
    this.maxAttendees,
    DateTime? createdAt,
  })  : attendees = attendees ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'eventDate': Timestamp.fromDate(eventDate),
      'organizer': organizer,
      'organizerId': organizerId,
      'attendees': attendees,
      'attendeesCount': attendeesCount,
      'category': category,
      'maxAttendees': maxAttendees,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map['eventId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? '',
      eventDate: (map['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      organizer: map['organizer'] ?? '',
      organizerId: map['organizerId'] ?? '',
      attendees: List<String>.from(map['attendees'] ?? []),
      attendeesCount: map['attendeesCount'] ?? 0,
      category: map['category'] ?? 'Other',
      maxAttendees: map['maxAttendees'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory EventModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel.fromMap(data);
  }

  bool isAttending(String userId) => attendees.contains(userId);

  bool get isUpcoming => eventDate.isAfter(DateTime.now());

  bool get isPast => eventDate.isBefore(DateTime.now());

  bool get isFull => maxAttendees != null && attendeesCount >= maxAttendees!;

  EventModel copyWith({
    String? eventId,
    String? title,
    String? description,
    String? imageUrl,
    String? location,
    DateTime? eventDate,
    String? organizer,
    String? organizerId,
    List<String>? attendees,
    int? attendeesCount,
    String? category,
    int? maxAttendees,
    DateTime? createdAt,
  }) {
    return EventModel(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      organizer: organizer ?? this.organizer,
      organizerId: organizerId ?? this.organizerId,
      attendees: attendees ?? this.attendees,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      category: category ?? this.category,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
