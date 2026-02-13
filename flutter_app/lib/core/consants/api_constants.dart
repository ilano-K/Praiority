import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {
  static const _port = 8000;

  static String get baseUrl {
    if (kReleaseMode) {
      return 'API URL DITO KARL';
    }

    // local host handling
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port';
    }
    return 'http://localhost:$_port';
  }

  //static endpoints

  static const String smartScheduleTask = '/api/v1/ai/schedule/fit';
  static const String smartOrganizeTask = '/api/v1/ai/schedule/organize';
  static const String smartGenerateTask = '/api/v1/ai/schedule/generate';
  static const String smartAdviceTask = '/api/v1/ai/advice/';
}
