import 'package:firebase_messaging/firebase_messaging.dart';
import 'logger.service.dart';
import 'notification.service.dart';

class FirebaseMessagingService {
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    String messageRecieved = message.toMap()['data']['message'];

    LoggerService.log('Recieve background message: $messageRecieved');
    NotificationService notificationService = NotificationService();
    await notificationService.showNotification(
        title: 'PITO Partner', body: messageRecieved);
  }

  static void init() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        LoggerService.log('Foreground message: ${message.notification}');
      }
    });
  }
}
