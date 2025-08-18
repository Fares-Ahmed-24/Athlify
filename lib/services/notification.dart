// import 'package:Athlify/services/admin_notify.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationHandler {
//   static void handle(RemoteMessage message) {
//     final notification = message.notification;
//     final data = message.data;

//     if (notification == null) return;

//     switch (data['type']) {
//       case 'role_status':
//         _handleRoleStatus(notification, data);
//         break;

//       case 'booking_update':
//         _handleBookingUpdate(notification, data);
//         break;

//       default:
//         _showLocalNotification(notification.title, notification.body);
//     }
//   }

//   static void _handleRoleStatus(
//       RemoteNotification notification, Map<String, dynamic> data) {
//     String statusMessage =
//         data['approved'] == "true" ? "✅ تم قبول طلبك!" : "❌ تم رفض طلبك.";

//     _showLocalNotification(
//         notification.title, "$statusMessage\n${notification.body}");
//   }

//   static void _handleBookingUpdate(
//       RemoteNotification notification, Map<String, dynamic> data) {
//     _showLocalNotification(notification.title, notification.body);
//   }

//   static void _showLocalNotification(String? title, String? body) {
//     flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'default_channel_id',
//           'Default',
//           importance: Importance.high,
//           priority: Priority.high,
//           icon: '@mipmap/ic_launcher',
//         ),
//       ),
//     );
//   }
// }
