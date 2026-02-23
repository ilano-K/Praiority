import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {
  static const _port = 8000;

  static const _localIp = '192.168.1.25';

  static String get baseUrl {
    if (kReleaseMode) {
      return 'API URL DITO KARL';
    }

    // local host handling
    if (Platform.isAndroid) {
      return 'http://$_localIp:$_port';
    }
    return 'http://$_localIp:$_port';
  }

  //static endpoints

  static const String smartScheduleTask = '/api/v1/ai/schedule/fit';
  static const String smartOrganizeTask = '/api/v1/ai/schedule/organize';
  static const String smartGenerateTask = '/api/v1/ai/schedule/generate';
  static const String smartAdviceTask = '/api/v1/ai/advice/';
}
