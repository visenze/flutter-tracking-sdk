import 'package:flutter/material.dart';
import 'package:visenze_tracking_sdk/visenze_tracker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String _trackerSid = '<unknown>';
  String _trackerUid = '<unknown>';
  String _requestResult = '<unknown>';
  late VisenzeTracker tracker;

  @override
  void initState() {
    super.initState();
    initTracker();
  }

  // Factory is asynchronous, so we put it in an async method.
  Future<void> initTracker() async {
    tracker = await VisenzeTracker.create('APP_KEY:PLACEMENT_ID');

    setState(() {
      _trackerSid = tracker.sessionId;
      _trackerUid = tracker.userId;
    });
  }

  Future<void> sendClickEvent() async {
    tracker.sendEvent('product_click', {'queryId': '1234', 'pid': 'Test pid'});
  }

  void onRequestSuccess() {
    setState(() {
      _requestResult = 'Request success';
    });
  }

  void onRequestError(String err) {
    setState(() {
      _requestResult = 'Request fail: $err';
    });
  }

  Future<void> sendATCEvent() async {
    tracker.sendEvent('add_to_cart', {'queryId': '1234', 'pid': 'Test pid'},
        onSuccess: onRequestSuccess, onError: onRequestError);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tracking SDK Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Session Id: $_trackerSid'),
              Text('User Id: $_trackerUid'),
              const Padding(padding: EdgeInsets.all(4)),
              TextButton(
                  onPressed: sendClickEvent,
                  child: const Text('Send click event')),
              const Padding(padding: EdgeInsets.all(4)),
              TextButton(
                  onPressed: sendATCEvent,
                  child: const Text('Send ATC event with callback')),
              Text(_requestResult),
            ],
          ),
        ),
      ),
    );
  }
}
