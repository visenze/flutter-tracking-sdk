import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:clock/clock.dart';

class SessionManager {
  static const String _keyUID = "visenze_uid";
  static const String _keySID = "visenze_sid";
  static const String _keySIDTimestamp = "visenze_sid_timestamp";
  static const int _sessionTimeout = 1800000;
  static const int _dayInMs = 86400000;
  static const _uuid = Uuid();

  late final SharedPreferences _prefs;
  String _uid = '';
  String _sid = '';
  int _sessionTimestamp = 0;

  /// Factory for creating [SessionManager]
  static Future<SessionManager> create([String? uid]) async {
    var session = SessionManager();
    await session._init(uid);
    return session;
  }

  /// Get the current session id
  /// Return a new session if the session id has expired
  String get sessionId {
    int now = clock.now().millisecondsSinceEpoch;
    if (_isSessionExpired(now)) {
      _sid = _uuid.v4().toString().replaceAll('-', '.');
    }
    // getSessionId is called means session is still active
    // update timestamp
    _sessionTimestamp = now;
    _saveSession();
    return _sid;
  }

  /// Get the current user id
  String get userId {
    return _uid;
  }

  /// Set user id to provided [uid]
  set userId(String uid) {
    _uid = uid;
    _prefs.setString(_keyUID, _uid);
  }

  int get sessionTimeRemaining {
    int now = clock.now().millisecondsSinceEpoch;
    var timestamp = _prefs.getInt(_keySIDTimestamp);
    if (timestamp == null) {
      return 0;
    }
    if (!_isSameDay(now, timestamp) || (now - timestamp) > _sessionTimeout) {
      return 0;
    }
    return _sessionTimeout - (now - timestamp);
  }

  String resetSession() {
    _prefs.remove(_keySID);
    _prefs.remove(_keySIDTimestamp);
    _sessionTimestamp = 0;
    return sessionId;
  }

  _init(String? uid) async {
    _prefs = await SharedPreferences.getInstance();
    _initUID(uid);
    _initSID();
  }

  void _initUID(String? uid) {
    if (uid != null && uid.isNotEmpty) {
      _uid = uid;
    } else {
      _uid = _prefs.getString(_keyUID) ?? '';
      if (_uid.isEmpty) {
        _uid = _uuid.v4().toString().replaceAll('-', '.');
      }
    }
    _prefs.setString(_keyUID, _uid);
  }

  void _initSID() {
    _sid = _prefs.getString(_keySID) ?? '';
    _sessionTimestamp = _prefs.getInt(_keySIDTimestamp) ?? 0;
  }

  bool _isSameDay(int t1, int t2) {
    double d1 = t1 / _dayInMs;
    double d2 = t2 / _dayInMs;
    return d1.toInt() == d2.toInt();
  }

  bool _isSessionExpired(int now) {
    return _sessionTimestamp == 0 ||
        (now - _sessionTimestamp > _sessionTimeout) ||
        !_isSameDay(_sessionTimestamp, now);
  }

  void _saveSession() {
    _prefs.setString(_keySID, _sid);
    _prefs.setInt(_keySIDTimestamp, _sessionTimestamp);
  }
}
