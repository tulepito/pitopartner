import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

import 'logger.service.dart';

class SendbirdService {
  static PushTokenType? _getPushTokenType() {
    PushTokenType? pushTokenType;
    if (Platform.isAndroid) {
      pushTokenType = PushTokenType.fcm;
    } else if (Platform.isIOS) {
      pushTokenType = PushTokenType.apns;
    }
    LoggerService.log('PushTokenType: $pushTokenType');
    return pushTokenType;
  }

  static Future<String?> _getToken() async {
    String? token;
    if (Platform.isAndroid) {
      token = await FirebaseMessaging.instance.getToken();
    } else if (Platform.isIOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
    }
    LoggerService.log('Token: $token');
    return token;
  }

  static void setPushTokenForUser(String userId) async {
    LoggerService.log('Setting push token for user $userId');
    await SendbirdChat.connect(userId)
        .then((value) =>
            LoggerService.log('Connected to Sendbird Chat SDK with $userId'))
        .catchError((error) => LoggerService.log(
            'Failed to connect to Sendbird Chat SDK: $error'));
    await SendbirdChat.registerPushToken(
      type: _getPushTokenType()!,
      token: (await _getToken())!,
      unique: true,
    );
  }

  static void removePushTokenForUser() async {
    LoggerService.log('Removing push token for user');
    await SendbirdChat.unregisterPushToken(
      type: _getPushTokenType()!,
      token: (await _getToken())!,
    ).then((value) => LoggerService.log('Unregistered push token')).catchError(
        (error) =>
            LoggerService.log('Failed to unregister push token: $error'));
    await SendbirdChat.disconnect();
  }
}
