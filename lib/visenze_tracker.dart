library visenze_tracking_sdk;

import 'dart:convert';
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

  /// Send a request to ViSenze analytics server with event name [action] and provided [queryParams]
  ///
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

  /// Send batch request to ViSenze analytics server with event name [action] and params list [queryParamsList]
  ///
  /// Execute [onSuccess] on each request success and [onError] on each request error
  Future<void> sendEvents(
      String action, List<Map<String, dynamic>> queryParamsList,
      {void Function()? onSuccess, void Function(String err)? onError}) async {
    for (final params in queryParamsList) {
      sendEvent(action, params, onSuccess: onSuccess, onError: onError);
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
    data['sid'] = _sessionManager.sessionId;
    data['uid'] = _sessionManager.userId;
    data['ts'] = DateTime.now().millisecondsSinceEpoch;
    data['action'] = action;
    data.addAll(queryParams);
    return data.map((key, value) => MapEntry(key, value.toString()));
  }
}
