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
      expect(tracker.getSessionId(), isNotEmpty);
    });

    test('persists across trackers', () async {
      var tracker1 = await VisenzeTracker.create(mockCode);
      String savedSid = tracker1.getSessionId();

      final tracker2 = await VisenzeTracker.create(mockCode);
      expect(tracker2.getSessionId(), equals(savedSid));
    });

    test('resets after timeout', () {
      fakeAsync((fakeTime) async {
        var tracker = await VisenzeTracker.create(mockCode);
        fakeTime.elapse(const Duration(milliseconds: 100));
        String savedSid = tracker.getSessionId();

        fakeTime.elapse(const Duration(milliseconds: 1800000));
        expect(tracker.getSessionId(), isNot(savedSid));
      });
    });
  });

  group('UID', () {
    test('is not empty', () async {
      var tracker = await VisenzeTracker.create(mockCode);
      expect(tracker.getUserId(), isNotEmpty);
    });

    test('is same as init UID', () async {
      var tracker = await VisenzeTracker.create(mockCode, uid: mockUID);
      expect(tracker.getUserId(), equals(mockUID));
    });

    test('persists across trackers', () async {
      var tracker1 = await VisenzeTracker.create(mockCode);
      String savedUid = tracker1.getUserId();

      final tracker2 = await VisenzeTracker.create(mockCode);
      expect(tracker2.getUserId(), equals(savedUid));
    });
  });
}
