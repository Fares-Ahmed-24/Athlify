import 'dart:convert';
import 'package:Athlify/views/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Athlify/constant/Constants.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel_id',
    'Default',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
  await fln.show(
    0,
    message.data['title'] ?? 'No title',
    message.data['body'] ?? 'No body',
    notificationDetails,
  );
}

class NotificationService {
  static Future<void> initNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
final navigatorKey = GlobalKey<NavigatorState>();
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationPage()),
        );
      },
    );

    String? token = await messaging.getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userType = prefs.getString('userType');

    if (token != null && userId != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/api/users/token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'token': token}),
        );
      } catch (e) {
        print("❌ Failed to send token to backend: $e");
      }
    }

    // ✅ اشترك في topic حسب نوع المستخدم
    if (userType != null) {
      await messaging
          .subscribeToTopic(userType); // مثال: admin, user, trainer...
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final data = message.data;
        final type = data['type'] ?? 'default';
        final target = data['target']; // 🎯 مهم

        // ✅ تجاهل الإشعار لو مش موجه لنفس نوع المستخدم
        if (target != userType) return;

        String title =
            data['title'] ?? message.notification?.title ?? 'Notification';
        String body = data['body'] ?? message.notification?.body ?? '';

        switch (type) {
          case 'role_status':
            body = (data['approved'] == "true"
                    ? "Your request approved ✅"
                    : "Your request rejected ❌.") +
                "\n" +
                body;
            break;
          case 'low_stock':
            body = "⚠️ $body";
            break;
          case 'booking_reminder':
            body = "⏰ $body"; // مثل: "Your booking starts in 1 hour"
            break;
          case 'new_booking':
            body = "📅 $body";
            break;
          case 'order_success':
            body = "✅ $body";
            break;
          default:
            break;


        }

        flutterLocalNotificationsPlugin.show(
          0,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel_id',
              'Default Channel',
              channelDescription: 'Channel for default notifications',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              styleInformation: BigTextStyleInformation(
                body,
                contentTitle: title,
                summaryText: '📩 Tap to view full message',
              ),
            ),
          ),
        );
      }
    });
  }

  static Future<List<Map<String, dynamic>>> fetchUserNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    final userId = prefs.getString('userId');

    if (userType == null || userId == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/type/$userType?userId=$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  static Future<void> markAsSeen(String notificationId) async {
    await http.patch(
      Uri.parse('$baseUrl/api/notifications/$notificationId/seen'),
    );
  }
}
