library visenze_tracking_sdk;

import 'package:visenze_tracking_sdk/src/data_collection.dart';
import 'package:visenze_tracking_sdk/src/session_manager.dart';
import 'package:http/http.dart' as http;

class VisenzeTracker {
  static const String _endpoint = 'analytics.data.visenze.com';
  static const String _stagingEndpoint = 'staging-analytics.data.visenze.com';
  static const String _path = 'v3/__va.gif';

  bool _useStaging = false;
  final String _code;
  late final SessionManager _sessionManager;
  late final DataCollection _deviceData;

  /// Factory for creating [VisenzeTracker]
  /// If [uid] is provided, set tracker user id to [uid]
  static Future<VisenzeTracker> create(code,
      {String? uid, bool? useStaging}) async {
    var tracker = VisenzeTracker._create(code, useStaging);
    await tracker._initSession(uid);
    return tracker;
  }

  /// Get the current session id
  String getSessionId() {
    return _sessionManager.getSessionId();
  }

  /// Get the current user id
  String getUserId() {
    return _sessionManager.getUserId();
  }

  /// Set the current user id to the provided [uid]
  void setUserId(String uid) {
    return _sessionManager.setUserId(uid);
  }

  /// Send a request to ViSenze analytics server with provided [queryParams]
  void send(Map<String, dynamic> queryParams) async {
    var trackingData = await _getTrackerParams();
    trackingData.addAll(queryParams);
    trackingData =
        trackingData.map((key, value) => MapEntry(key, value.toString()));
    Uri url = Uri.https(
        _useStaging ? _stagingEndpoint : _endpoint, _path, trackingData);
    http.get(url);
  }

  VisenzeTracker._create(this._code, [bool? useStaging]) {
    _deviceData = DataCollection();
    _useStaging = useStaging ?? false;
  }

  Future<void> _initSession(String? uid) async {
    _sessionManager = await SessionManager.create(uid);
  }

  Future<Map<String, dynamic>> _getTrackerParams() async {
    Map<String, dynamic> data = await _deviceData.readDeviceData();
    data['code'] = _code;
    data['sid'] = _sessionManager.getSessionId();
    data['uid'] = _sessionManager.getUserId();
    data['ts'] = DateTime.now().millisecondsSinceEpoch;
    return data;
  }
}
