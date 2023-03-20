# visenze-tracking-sdk

[![Pub](https://img.shields.io/pub/v/visenze_tracking_sdk.svg)](https://pub.dev/packages/visenze_tracking_sdk)
[![Platform](https://img.shields.io/badge/Platform-Android_iOS_Web-blue.svg?longCache=true&style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](/LICENSE)
[![Null Safety](https://img.shields.io/badge/-Null%20Safety-blue.svg)]()

## Overview
Visenze Analytics is a key part of your analytics solutions, allowing you to track key events and view the resulting analytics and performance data. 

The ViSenze Tracking SDK is an open source software for easy integration of ViSearch Tracking API with your javascript application. For source code and references, visit the [GitHub repository](https://github.com/visenze/flutter-tracking-sdk).

## Usage

```dart
import 'package:visenze_tracking_sdk/visenze_tracker.dart';

void main() {
  var tracker = await VisenzeTracker.create('MY_APP_KEY:MY_PLACEMENT_ID');
}
```
