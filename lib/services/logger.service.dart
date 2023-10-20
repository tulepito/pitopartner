import 'package:flutter/foundation.dart';

class LoggerService {
  static void log(String message) {
    if (kDebugMode) {
      print('EVENT =============>>>>>>>>> $message');
    }
  }
}
