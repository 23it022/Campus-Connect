import 'package:cloud_firestore/cloud_firestore.dart';

/// QR Scanner Service
/// Handles parsing scanned QR data and resolving CampusConnect content types

enum QrContentType { profile, event, group, url, text }

class QrScanResult {
  final String rawData;
  final QrContentType type;
  final String? id; // The parsed ID for CampusConnect content
  final String displayLabel;

  QrScanResult({
    required this.rawData,
    required this.type,
    this.id,
    required this.displayLabel,
  });
}

class QrScannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Parse raw scanned data into a structured result
  QrScanResult parseScannedData(String rawData) {
    final trimmed = rawData.trim();

    // CampusConnect deep link patterns
    if (trimmed.startsWith('campusconnect://profile/')) {
      final id = trimmed.replaceFirst('campusconnect://profile/', '');
      return QrScanResult(
        rawData: trimmed,
        type: QrContentType.profile,
        id: id,
        displayLabel: 'Student Profile',
      );
    }

    if (trimmed.startsWith('campusconnect://event/')) {
      final id = trimmed.replaceFirst('campusconnect://event/', '');
      return QrScanResult(
        rawData: trimmed,
        type: QrContentType.event,
        id: id,
        displayLabel: 'Campus Event',
      );
    }

    if (trimmed.startsWith('campusconnect://group/')) {
      final id = trimmed.replaceFirst('campusconnect://group/', '');
      return QrScanResult(
        rawData: trimmed,
        type: QrContentType.group,
        id: id,
        displayLabel: 'Study Group',
      );
    }

    // Generic URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return QrScanResult(
        rawData: trimmed,
        type: QrContentType.url,
        displayLabel: 'Web Link',
      );
    }

    // Plain text
    return QrScanResult(
      rawData: trimmed,
      type: QrContentType.text,
      displayLabel: 'Text',
    );
  }

  /// Look up a user's display name by UID
  Future<String?> getUserName(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['displayName'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Look up an event title by ID
  Future<String?> getEventTitle(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return doc.data()?['title'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Look up a group name by ID
  Future<String?> getGroupName(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        return doc.data()?['name'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Generate a CampusConnect deep link for a profile
  String generateProfileLink(String uid) => 'campusconnect://profile/$uid';

  /// Generate a CampusConnect deep link for an event
  String generateEventLink(String eventId) =>
      'campusconnect://event/$eventId';

  /// Generate a CampusConnect deep link for a group
  String generateGroupLink(String groupId) =>
      'campusconnect://group/$groupId';
}
