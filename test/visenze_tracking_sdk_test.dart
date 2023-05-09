import 'package:flutter_test/flutter_test.dart';
import 'package:visenze_tracking_sdk/visenze_tracker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  const mockCode = 'abc:1';
  const mockUID = 'My UID';

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  tearDown(() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  });

  group('SID', () {
    test('is not empty', () async {
      var tracker = await VisenzeTracker.create(mockCode);
      expect(tracker.sessionId, isNotEmpty);
    });

    test('persists across trackers', () async {
      var tracker1 = await VisenzeTracker.create(mockCode);
      String savedSid = tracker1.sessionId;

      final tracker2 = await VisenzeTracker.create(mockCode);
      expect(tracker2.sessionId, equals(savedSid));
    });

    test('resets after timeout', () {
      fakeAsync((fakeTime) async {
        var tracker = await VisenzeTracker.create(mockCode);
        fakeTime.elapse(const Duration(milliseconds: 100));
        String savedSid = tracker.sessionId;

        fakeTime.elapse(const Duration(milliseconds: 1800000));
        expect(tracker.sessionId, isNot(savedSid));
      });
    });
  });

  group('UID', () {
    test('is not empty', () async {
      var tracker = await VisenzeTracker.create(mockCode);
      expect(tracker.userId, isNotEmpty);
    });

    test('is same as init UID', () async {
      var tracker = await VisenzeTracker.create(mockCode, uid: mockUID);
      expect(tracker.userId, equals(mockUID));
    });

    test('is set correctly', () async {
      var tracker = await VisenzeTracker.create(mockCode, uid: mockUID);
      String oldUid = tracker.userId;
      expect(oldUid, isNotEmpty);

      tracker.userId = 'new uid';
      expect(tracker.userId, isNot(oldUid));
    });

    test('persists across trackers', () async {
      var tracker1 = await VisenzeTracker.create(mockCode);
      String savedUid = tracker1.userId;

      final tracker2 = await VisenzeTracker.create(mockCode);
      expect(tracker2.userId, equals(savedUid));
    });
  });
}
