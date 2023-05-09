import 'dart:convert';

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

  final TextEditingController _eventController =
      TextEditingController(text: 'product_click');
  final TextEditingController _paramsController =
      TextEditingController(text: '{"pid": "Test PID", "queryId": "1234"}');

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

  void onRequestSuccess() {
    setState(() {
      _requestResult = 'Request success';
    });
  }

  void onRequestError(dynamic err) {
    setState(() {
      _requestResult = 'Request fail: $err';
    });
  }

  Future<void> sendEvent() async {
    try {
      await tracker.sendEvent(
          _eventController.text, jsonDecode(_paramsController.text));
      onRequestSuccess();
    } catch (err) {
      onRequestError(err);
    }
  }

  Future<void> resetSession() async {
    tracker.resetSession();
    setState(() {
      _trackerSid = tracker.sessionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Tracking SDK Demo'),
          ),
          body: SingleChildScrollView(
            child: Container(
                height: 800,
                padding: EdgeInsets.all(15),
                child: ListView(
                  children: <Widget>[
                    Text('Session Id: $_trackerSid'),
                    Text('User Id: $_trackerUid'),
                    const Padding(padding: EdgeInsets.all(4)),
                    TextButton(
                        onPressed: resetSession,
                        child: const Text('Reset session')),
                    const Padding(padding: EdgeInsets.all(4)),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Event name",
                      ),
                      controller: _eventController,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Event params",
                      ),
                      controller: _paramsController,
                    ),
                    const Padding(padding: EdgeInsets.all(4)),
                    TextButton(
                        onPressed: sendEvent, child: const Text('Send event')),
                    Text(_requestResult),
                  ],
                )),
          )),
    );
  }
}
