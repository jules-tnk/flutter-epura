import 'package:flutter/services.dart';

class AndroidSettingsService {
  static const String channelName = 'com.epura.cleaner/android_settings';
  static const MethodChannel _channel = MethodChannel(channelName);

  const AndroidSettingsService();

  Future<bool> openStorageSettings() async {
    try {
      return await _channel.invokeMethod<bool>('openStorageSettings') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
