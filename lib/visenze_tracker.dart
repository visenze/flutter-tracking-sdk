library visenze_tracking_sdk;

import 'dart:convert';
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

  /// Send a request to ViSenze analytics server with event name [action] and provided [queryParams]
  /// Execute [onSuccess] on request success and [onError] on request error
  Future<void> sendEvent(String action, Map<String, dynamic> queryParams,
      {void Function()? onSuccess, void Function(String err)? onError}) async {
    var trackingData = await _getTrackerParams(action, queryParams);
    Uri url = Uri.https(
        _useStaging ? _stagingEndpoint : _endpoint, _path, trackingData);

    var response = await http.get(url);
    if (response.statusCode == 200 && onSuccess != null) {
      onSuccess();
    } else if (response.statusCode != 200 && onError != null) {
      Map<String, dynamic> body = jsonDecode(response.body);
      onError(body['error']['message']);
    }
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
    data['sid'] = _sessionManager.getSessionId();
    data['uid'] = _sessionManager.getUserId();
    data['ts'] = DateTime.now().millisecondsSinceEpoch;
    data['action'] = action;
    data.addAll(queryParams);
    return data.map((key, value) => MapEntry(key, value.toString()));
  }
}
