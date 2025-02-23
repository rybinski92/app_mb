import 'package:flutter/services.dart';

class Config {
  static const MethodChannel _channel = MethodChannel('config');

  static Future<String?> getApiKey1() async {
    final String? apiKey1 = await _channel.invokeMethod('getApiKey1');
    return apiKey1;
  }

  static Future<String?> getApiKey2() async {
    final String? apiKey2 = await _channel.invokeMethod('getApiKey2');
    // print("Received API Key 2: $apiKey2");  
    return apiKey2;
  }

  static Future<String?> getApiKey3() async {
    final String? apiKey3 = await _channel.invokeMethod('getApiKey3');
    return apiKey3;
  }

  static Future<String?> getApiKey4() async {
    final String? apiKey4 = await _channel.invokeMethod('getApiKey4');
    return apiKey4;
  }
}