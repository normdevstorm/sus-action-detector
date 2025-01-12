import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

class FirebaseMessageService {
  static Future<void> initNotificaiton() async {
    // await Firebase.initializeApp(
    //   options:
    //       firebase_options_cloud_message.DefaultFirebaseOptions.currentPlatform,
    // );
    final firebaseMessaging = FirebaseMessaging.instance;
    final fcmToken = await firebaseMessaging.getToken();
    if (fcmToken != null) {
      Logger().i("FCMToken: $fcmToken");
    }
      final firebaseInstallationId =
          await FirebaseInstallations.instance.getId();
      Logger().i("InstallationId: $firebaseInstallationId");
      requestNotificationPermissions(firebaseMessaging);
      FirebaseMessaging.onBackgroundMessage(_handlerBackgorundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Logger().i("onMessageOpenedApp: $message");
    });
  }
}

Future<void> _handlerBackgorundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  Logger().i("onBackgroundMessage: $message");
}

Future<void> requestNotificationPermissions(FirebaseMessaging messaging) async {
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    Logger().i('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    Logger().i('User granted provisional permission');
  } else {
    Logger().i('User declined or has not accepted permission');
  }
}
