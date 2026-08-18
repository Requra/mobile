import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Singleton service that listens for incoming deep links.
///
/// Usage:
///   await DeepLinkService.instance.init();
///   DeepLinkService.instance.onDeepLink.listen((link) { ... });
class MeetingDeepLink {
  final String meetingId;
  final String? token;
  MeetingDeepLink({required this.meetingId, this.token});
}

class DeepLinkService {
  static final DeepLinkService instance = DeepLinkService._();
  DeepLinkService._();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final _deepLinkController = StreamController<MeetingDeepLink>.broadcast();

  // Expose stream of valid meeting deep links
  Stream<MeetingDeepLink> get onDeepLink => _deepLinkController.stream;

  // Expose stream of ClickUp callbacks
  final _clickUpCallbackController = StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get onClickUpCallback => _clickUpCallbackController.stream;

  // Pending meeting link saved when user is not logged in or during cold start
  MeetingDeepLink? _pendingMeetingLink;
  MeetingDeepLink? get pendingMeetingLink => _pendingMeetingLink;
  
  void clearPending() => _pendingMeetingLink = null;
  void savePending(MeetingDeepLink link) => _pendingMeetingLink = link;

  Future<void> init() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri, isInitial: true);
      }
    } catch (e) {
      debugPrint("Failed to get initial link: $e");
    }

    // Listen for incoming links when app is in foreground/background
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri, isInitial: false);
    }, onError: (err) {
      debugPrint("Failed to get latest link: $err");
    });
  }

  void _handleUri(Uri uri, {bool isInitial = false}) {
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
    final link = parseMeetingLink(uri);
    if (link != null) {
      if (isInitial) {
        _pendingMeetingLink = link;
      } else {
        _deepLinkController.add(link);
      }
    }
  }

  /// Parses a URI and returns the MeetingDeepLink if valid.
  /// Returns null for invalid/unrecognized links.
  static MeetingDeepLink? parseMeetingLink(Uri uri) {
    final segments = uri.pathSegments;
    
    // New format: /meeting/join?meetingId=...&Token=... or &guestToken=...
    if (segments.length >= 2 &&
        segments[0] == 'meeting' &&
        segments[1] == 'join') {
      final meetingId = uri.queryParameters['meetingId'];
      final token = uri.queryParameters['guestToken'] ?? uri.queryParameters['Token'];
      if (meetingId != null) {
        return MeetingDeepLink(meetingId: meetingId, token: token);
      }
    }
    
    // Old format: /meetings/{uuid}/join
    if (segments.length >= 3 &&
        segments[0] == 'meetings' &&
        segments[2] == 'join') {
      return MeetingDeepLink(meetingId: segments[1]);
    }
    
    return null;
  }

  void dispose() {
    _linkSubscription?.cancel();
    _deepLinkController.close();
  }
}
