import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/firebase_options.dart';
import 'package:tamdansers_lv2/screens/notification/notification_view.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BaseApiService baseApiService = BaseApiService();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> setupLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');

  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> saveFcmTokenToBackend(String token) async {
  try {
    await baseApiService.post(
      endpoint: "/notifications/fcm-token",
      data: {
        "token": token,
      },
    );

    print("FCM Token saved to backend");
  } catch (e) {
    print("Save FCM Token Error: $e");
  }
}

Future<void> setupFCM() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final token = await messaging.getToken();

  if (token != null) {
    print("FCM Token: $token");
    await saveFcmTokenToBackend(token);
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print("New FCM Token: $newToken");
    await saveFcmTokenToBackend(newToken);
  });

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    if (Get.isRegistered<NotificationController>()) {
      await Get.find<NotificationController>().loadNotifications();
    }
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (Get.isRegistered<NotificationController>()) {
      await Get.find<NotificationController>().loadNotifications();
    }

    final title =
        message.notification?.title ?? message.data["title"] ?? "Notification";

    final body = message.notification?.body ??
        message.data["body"] ??
        message.data["message"] ??
        "";

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/ic_notification',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if (Get.isRegistered<NotificationController>()) {
      await Get.find<NotificationController>().loadNotifications();
    }

    print("User tapped notification");
  });
}