# visenze-tracking-sdk

[![Pub](https://img.shields.io/pub/v/visenze_tracking_sdk.svg)](https://pub.dev/packages/visenze_tracking_sdk)
[![Platform](https://img.shields.io/badge/Platform-Android_iOS_Web-blue.svg?longCache=true&style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](/LICENSE)
[![Null Safety](https://img.shields.io/badge/-Null%20Safety-blue.svg)]()

## Table of Contents

- [visenze-tracking-javascript](#visenze-tracking-javascript)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Usage](#usage)
    - [Installing](#installing)
    - [Importing](#importing)
    - [Setting user is](#setting-user-id)
    - [Getting tracking data](#getting-tracking-data)
    - [Sending events](#sending-events)
  - [Event parameters](#event-parameters)
  - [Example](#example)

## Overview

Visenze Analytics is a key part of your analytics solutions, allowing you to track key events and view the resulting analytics and performance data.

The ViSenze Tracking SDK is an open source software for easy integration of ViSearch Tracking API with your flutter application. For source code and references, visit the [GitHub repository](https://github.com/visenze/flutter-tracking-sdk).

## Usage

### Installing

Run this command

```
flutter pub add visenze_tracking_sdk
```

### Importing

```dart
import 'package:visenze_tracking_sdk/visenze_tracker.dart';

Future<void> init() async {
  var tracker = await VisenzeTracker.create('MY_APP_KEY:MY_PLACEMENT_ID');
}
```

### Setting user id

```dart
tracker.userId = 'MY_UID'
```

### Getting tracking data

```dart
String uid = tracker.userId;
String sid = tracker.sessionId;
```

### Sending events

All events sent to Visenze Analytics server require the search query ID (the reqid) found in the search results response as part of the request parameter.

Some events (for e.g. `product_click` or `product_view`) can require additional parameter like `pid` (product id).

#### Single events

User action can be sent through an event handler. Register an event handler to the element in which the user will interact.

```dart
// send product click
tracker.sendEvent('product_click', {
  'queryId': '<search reqid>',
  'pid': '<your product id>', // necessary for product_click event
  'pos': 1, // product position in Search Results, start from 1
});

// send product impression
tracker.sendEvent('product_view', {
  'queryId': '<search reqid>',
  'pid': '<your product id>', // necessary for product_view event
  'pos': 1, // product position in Search Results, start from 1
});

// send Transaction event e.g order purchase of $300
tracker.sendEvent('transaction', {
  'queryId': "<search reqid>",
  'transId': "<your transaction ID>"
  'value': 300
});

// send Add to Cart Event
tracker.sendEvent('add_to_cart', {
  'queryId': '<search reqid>',
  'pid': '<your product id>',
  'pos': 1, // product position in Search Results, start from 1
});

// send custom event
tracker.sendEvent('favourite', {
  'queryId': '<search reqid>',
  'pid': 'custom event label',
  'cat': '<product category>'
});

// handle success or error
try {
  await tracker.sendEvent('product_view', {
    'queryId': '1234',
    'pid': 'Product Id',
    'pos': 1
  });
  onRequestSuccess() // handle success case
} catch (errResponse) {
  onRequestError(errResponse) // handle error case
}
```

#### Batch events

Batch actions can be sent through a batch event handler.

A common use case for this batch event method is to group up all transaction by sending it in a batch. This SDK will automatically generate a transId to group transactions as an order.

```dart
const transactions = [
  {'queryId': '1234', 'pid': 'Pid 1', 'value': 50},
  {'queryId': '1234', 'pid': 'Pid 2', 'value': 100}
];
tracker.sendEvents('transactions', transactions);
```

### Event parameters

For the detailed list of event parameters, please refer to this [doc](https://ref-docs.visenze.com/reference/event-parameters).

## Example

[Example](https://pub.dev/packages/visenze_tracking_sdk/example)
