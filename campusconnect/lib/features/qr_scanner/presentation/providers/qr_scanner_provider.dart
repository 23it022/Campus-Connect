import 'package:flutter/foundation.dart';
import '../../data/services/qr_scanner_service.dart';

/// QR Scanner Provider
/// Manages scan state, last scanned result, and scan history

class QrScannerProvider extends ChangeNotifier {
  final QrScannerService _service = QrScannerService();

  QrScanResult? _lastResult;
  final List<QrScanResult> _scanHistory = [];
  bool _isProcessing = false;
  String? _resolvedName; // e.g. resolved user name, event title

  QrScanResult? get lastResult => _lastResult;
  List<QrScanResult> get scanHistory => List.unmodifiable(_scanHistory);
  bool get isProcessing => _isProcessing;
  String? get resolvedName => _resolvedName;

  /// Process a raw scanned string
  Future<QrScanResult> processScan(String rawData) async {
    _isProcessing = true;
    _resolvedName = null;
    notifyListeners();

    final result = _service.parseScannedData(rawData);
    _lastResult = result;
    _scanHistory.insert(0, result);

    // Resolve the name for CampusConnect deep links
    if (result.type == QrContentType.profile && result.id != null) {
      _resolvedName = await _service.getUserName(result.id!);
    } else if (result.type == QrContentType.event && result.id != null) {
      _resolvedName = await _service.getEventTitle(result.id!);
    } else if (result.type == QrContentType.group && result.id != null) {
      _resolvedName = await _service.getGroupName(result.id!);
    }

    _isProcessing = false;
    notifyListeners();
    return result;
  }

  /// Clear the last result (dismiss bottom sheet)
  void clearLastResult() {
    _lastResult = null;
    _resolvedName = null;
    notifyListeners();
  }

  /// Clear scan history
  void clearHistory() {
    _scanHistory.clear();
    notifyListeners();
  }

  /// Generate a profile QR link
  String generateProfileLink(String uid) =>
      _service.generateProfileLink(uid);

  /// Generate an event QR link
  String generateEventLink(String eventId) =>
      _service.generateEventLink(eventId);

  /// Generate a group QR link
  String generateGroupLink(String groupId) =>
      _service.generateGroupLink(groupId);
}
