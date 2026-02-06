
import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {
  static const _port = 8000;

  static String get baseUrl {
    if (kReleaseMode){
      return 'API URL DITO KARL';
    }

    // local host handling
    if (Platform.isAndroid){
      return 'http://10.0.2.2:$_port';
    }
    return 'http://localhost:$_port';
  }

  //static endpoints
  static const String smartSched = '/api/v1/ai/schedule/';
  static const String smartOrganize = '/api/v1/ai/organize/';
  static const String smartAdvice = '/api/v1/ai/advice/';
}