import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Singleton service that listens for incoming deep links.
///
/// Usage:
///   await DeepLinkService.instance.init();
///   DeepLinkService.instance.onDeepLink.listen((meetingId) { ... });
class DeepLinkService {
  static final DeepLinkService instance = DeepLinkService._();
  DeepLinkService._();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final _deepLinkController = StreamController<String>.broadcast();

  // Expose stream of valid meeting IDs extracted from deep links
  Stream<String> get onDeepLink => _deepLinkController.stream;

  // Expose stream of ClickUp callbacks
  final _clickUpCallbackController = StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get onClickUpCallback => _clickUpCallbackController.stream;

  // Pending meeting ID saved when user is not logged in
  String? _pendingMeetingId;
  String? get pendingMeetingId => _pendingMeetingId;
  
  void clearPending() => _pendingMeetingId = null;
  void savePending(String meetingId) => _pendingMeetingId = meetingId;

  Future<void> init() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint("Failed to get initial link: $e");
    }

    // Listen for incoming links when app is in foreground/background
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    }, onError: (err) {
      debugPrint("Failed to get latest link: $err");
    });
  }

  void _handleUri(Uri uri) {
    debugPrint("Received deep link: $uri");
    
    // ClickUp OAuth callback: requra://clickup/callback?code=XXX&state=YYY
    if (uri.scheme == 'requra' && uri.host == 'clickup') {
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state']; // = projectId
      if (code != null && state != null) {
        _clickUpCallbackController.add({'code': code, 'projectId': state});
      }
      return;
    }
    
    // Existing meeting deep link logic
    final meetingId = parseMeetingId(uri);
    if (meetingId != null) {
      _deepLinkController.add(meetingId);
    }
  }

  /// Parses a URI and returns the meetingId if valid.
  /// Returns null for invalid/unrecognized links.
  static String? parseMeetingId(Uri uri) {
    // Matches: /meetings/{uuid}/join
    final segments = uri.pathSegments;
    if (segments.length >= 3 &&
        segments[0] == 'meetings' &&
        segments[2] == 'join') {
      return segments[1]; // the meetingId
    }
    return null;
  }

  void dispose() {
    _linkSubscription?.cancel();
    _deepLinkController.close();
  }
}
