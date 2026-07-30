import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    'Background notification received: ${message.messageId}',
  );
}

Future<void> setupLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('ic_launcher_foreground');

  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (
      NotificationResponse response,
    ) async {
      debugPrint(
        'Local notification tapped: ${response.payload}',
      );
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> saveFcmTokenToBackend(
  String fcmToken,
) async {
  final storage = GetStorage();

  /*
   * IMPORTANT:
   * Change "access_token" to the key used in your login code.
   *
   * Example:
   * GetStorage().write("access_token", token);
   *
   * If you save it as "token", change this to:
   * storage.read<String>("token");
   */
  final accessToken =
      storage.read<String>('access_token');

  if (accessToken == null || accessToken.isEmpty) {
    debugPrint(
      'Skip FCM token: user is not authenticated',
    );
    return;
  }

  try {
    await baseApiService.post(
      endpoint: '/notifications/fcm-token',
      data: {
        'token': fcmToken,
      },
    );

    debugPrint('FCM Token saved to backend');
  } catch (e) {
    debugPrint('Save FCM Token Error: $e');
  }
}

Future<void> setupFCM() async {
  try {
    final FirebaseMessaging messaging =
        FirebaseMessaging.instance;

    final NotificationSettings settings =
        await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'Notification permission: '
      '${settings.authorizationStatus}',
    );

    final String? fcmToken =
        await messaging.getToken();

    if (fcmToken != null &&
        fcmToken.isNotEmpty) {
      debugPrint('FCM Token received');

      await saveFcmTokenToBackend(
        fcmToken,
      );
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (String newToken) async {
        debugPrint('New FCM Token received');

        await saveFcmTokenToBackend(
          newToken,
        );
      },
      onError: (Object error) {
        debugPrint(
          'FCM token refresh error: $error',
        );
      },
    );

    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance
            .getInitialMessage();

    if (initialMessage != null) {
      await _handleNotificationTap(
        initialMessage,
      );
    }

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        await _refreshNotificationList();

        final String title =
            message.notification?.title ??
                message.data['title']?.toString() ??
                'Notification';

        final String body =
            message.notification?.body ??
                message.data['body']?.toString() ??
                message.data['message']?.toString() ??
                '';

        await flutterLocalNotificationsPlugin.show(
          DateTime.now()
                  .millisecondsSinceEpoch ~/
              1000,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription:
                  channel.description,
              importance: Importance.max,
              priority: Priority.max,
              playSound: true,
              enableVibration: true,
              icon: '@drawable/ic_notification',
            ),
            iOS:
                const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      },
      onError: (Object error) {
        debugPrint(
          'Foreground FCM error: $error',
        );
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        await _handleNotificationTap(
          message,
        );
      },
      onError: (Object error) {
        debugPrint(
          'Notification tap error: $error',
        );
      },
    );
  } catch (e) {
    debugPrint('Setup FCM Error: $e');
  }
}

Future<void> _handleNotificationTap(
  RemoteMessage message,
) async {
  debugPrint(
    'User tapped notification: '
    '${message.messageId}',
  );

  await _refreshNotificationList();

  // Optional:
  // Navigate to notification page
  //
  // if (Get.currentRoute != '/notification') {
  //   Get.toNamed('/notification');
  // }
  // if (token != null) {
  //   print("FCM Token: $token");
  //   await saveFcmTokenToBackend(token);
  // }

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
          icon: 'ic_launcher_foreground',
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

Future<void> _refreshNotificationList() async {
  if (Get.isRegistered<NotificationController>()) {
    try {
      await Get.find<NotificationController>()
          .loadNotifications();
    } catch (e) {
      debugPrint(
        'Load notifications error: $e',
      );
    }
  }
}

Future<void> saveCurrentFcmTokenAfterLogin() async {
  try {
    final String? fcmToken =
        await FirebaseMessaging.instance.getToken();

    if (fcmToken == null ||
        fcmToken.isEmpty) {
      debugPrint(
        'Cannot save FCM token: token is empty',
      );
      return;
    }

    await saveFcmTokenToBackend(
      fcmToken,
    );
  } catch (e) {
    debugPrint(
      'Save current FCM token error: $e',
    );
  }
}