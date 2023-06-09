library visenze_tracking_sdk;

import 'package:visenze_tracking_sdk/src/data_collection.dart';
import 'package:visenze_tracking_sdk/src/session_manager.dart';
import 'package:http/http.dart' as http;

class VisenzeTracker {
  static const String _endpoint = 'analytics.data.visenze.com';
  static const String _stagingEndpoint = 'staging-analytics.data.visenze.com';
  static const String _path = 'v3/__va.gif';

  final String _code;
  late final SessionManager _sessionManager;
  late final DataCollection _deviceData;
  late final bool _useStaging;

  /// Factory for creating [VisenzeTracker]
  ///
  /// If [uid] is provided, set tracker user id to [uid]
  static Future<VisenzeTracker> create(code,
      {String? uid, bool? useStaging}) async {
    var tracker = VisenzeTracker._create(code, useStaging);
    await tracker._initSession(uid);
    return tracker;
  }

  /// Get the current session id
  String get sessionId {
    return _sessionManager.sessionId;
  }

  /// Get the current user id
  String get userId {
    return _sessionManager.userId;
  }

  /// Set the current user id to the provided [uid]
  set userId(String uid) {
    _sessionManager.userId = uid;
  }

  /// Return remaining time for session
  int get sessionTimeRemaining {
    return _sessionManager.sessionTimeRemaining;
  }

  /// Reset the current session and return the new sessionId
  String resetSession() {
    return _sessionManager.resetSession();
  }

  /// Send a request to ViSenze analytics server with event name [action] and provided [queryParams]
  Future<void> sendEvent(
      String action, Map<String, dynamic> queryParams) async {
    var trackingData = await _getTrackerParams(action, queryParams);
    Uri url = Uri.https(
        _useStaging ? _stagingEndpoint : _endpoint, _path, trackingData);
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      return Future.error(resp.body);
    }
  }

  /// Send batch request to ViSenze analytics server with event name [action] and params list [queryParamsList]
  Future<void> sendEvents(
      String action, List<Map<String, dynamic>> queryParamsList) async {
    final batchId = _sessionManager.generateUUID();
    final List<Future> futures = [];
    for (final params in queryParamsList) {
      if (action == 'transaction') {
        if (params['transId'] == null || params['transId'] == '') {
          params['transId'] = batchId;
        }
      }
      futures.add(sendEvent(action, params));
    }
    await Future.wait(futures);
  }

  VisenzeTracker._create(this._code, [bool? useStaging]) {
    _deviceData = DataCollection();
    _useStaging = useStaging ?? false;
  }

  Future<void> _initSession(String? uid) async {
    _sessionManager = await SessionManager.create(uid);
  }

  Future<Map<String, String>> _getTrackerParams(
      String action, Map<String, dynamic> queryParams) async {
    Map<String, dynamic> data = await _deviceData.readDeviceData();
    data['code'] = _code;
    data['sid'] = _sessionManager.sessionId;
    data['uid'] = _sessionManager.userId;
    data['ts'] = DateTime.now().millisecondsSinceEpoch;
    data['action'] = action;
    data.addAll(queryParams);
    return data.map((key, value) => MapEntry(key, value.toString()));
  }
}
