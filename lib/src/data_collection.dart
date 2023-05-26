import 'dart:ui';
import 'package:universal_io/io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DataCollection {
  static const String _sdk = 'flutter_sdk';
  static const String _version = '0.0.4';
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Get platform data
  Future<Map<String, dynamic>> readDeviceData() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData =
            _readWebBrowserInfo(await _deviceInfoPlugin.webBrowserInfo);
      } else {
        if (Platform.isAndroid) {
          deviceData =
              _readAndroidBuildData(await _deviceInfoPlugin.androidInfo);
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo);
        } else if (Platform.isLinux) {
          deviceData = _readLinuxDeviceInfo(await _deviceInfoPlugin.linuxInfo);
        } else if (Platform.isMacOS) {
          deviceData = _readMacOsDeviceInfo(await _deviceInfoPlugin.macOsInfo);
        } else if (Platform.isWindows) {
          deviceData =
              _readWindowsDeviceInfo(await _deviceInfoPlugin.windowsInfo);
        }
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    deviceData.addAll(await _getCommonData());
    return deviceData;
  }

  Future<Map<String, dynamic>> _getCommonData() async {
    return {
      'sdk': _sdk,
      'v': _version,
      'lang': _getLanguage(),
      'sr': _getScreenResolution(),
    };
  }

  // Get width and height of the device's screen in physical pixels
  String _getScreenResolution() {
    var size = window.physicalSize;
    var width = size.width;
    var height = size.height;
    return '${width.toInt()}x${height.toInt()}';
  }

  String _getLanguage() {
    return window.locale.toString();
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'p': 'Mobile',
      'os': 'Android',
      'osv': build.version.baseOS,
      'db': build.manufacturer,
      'dm': build.model,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'p': 'Mobile',
      'os': 'iOS',
      'osv': data.systemVersion,
      'db': 'Apple',
      'dm': 'Apple ${data.model}',
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'os': 'Linux',
      'osv': data.version,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{'url': Uri.base};
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'os': 'MacOS',
      'osv': data.osRelease,
      'db': 'Apple',
      'dm': data.model,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'os': 'Windows',
      'osv': '${data.majorVersion}.${data.minorVersion}'
    };
  }
}
