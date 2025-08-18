import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/functions/fromTimeAgo.dart';
import 'package:Athlify/services/admin_notify.dart';
import 'package:Athlify/views/Drawer_pages/requestPage.dart';
import 'package:Athlify/views/bottom_nav_view/ClubsTab.dart';
import 'package:Athlify/views/dashboard/DashboardAdmin/marketDashboard.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = NotificationService.fetchUserNotifications();
  }

  void _refresh() {
    setState(() {
      _notificationsFuture = NotificationService.fetchUserNotifications();
    });
  }

  Icon getNotificationIcon(String? type, bool seen) {
    final color = seen ? Colors.grey : Colors.orange;

    switch (type) {
      case 'low_stock':
        return Icon(Icons.warning, color: color);
      case 'role_status':
        return Icon(Icons.verified_user, color: color);
      case 'booking_update':
        return Icon(Icons.calendar_today, color: color);
      case 'custom_message':
        return Icon(Icons.message, color: color);
      case 'order_success':
        return Icon(Icons.check_circle,
            color: color); // ✅ أضفت أيقونة نجاح الطلب
      case 'new_booking':
        return Icon(Icons.event_available,
            color: color); // أو Icon(Icons.sports_soccer)

      default:
        return Icon(Icons.notifications, color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No notifications.'));
                }

                final notifications = snapshot.data!;
                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final seen = notif['seen'] ?? false;
                    final type = notif['type'];
                    final timestamp =
                        DateTime.tryParse(notif['timestamp'] ?? '');
                    final timeAgo = formatTimeAgo(timestamp);

                    return GestureDetector(
                      onTap: () async {
                        if (!seen) {
                          await NotificationService.markAsSeen(notif['_id']);
                          _refresh();
                        }

                        final notifType = notif['type'];

                        switch (notifType) {
                          case 'role_status':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const Requestpage()),
                            );
                            break;
                          case 'low_stock':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const Marketdashboard()),
                            );
                            break;
                          case 'booking_update':
                          case 'new_booking':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ClubsTab()),
                            );
                            break;
                          case 'order_success':
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (_) => const OrdersPage()),
                            // );
                            break;
                          default:
                            break;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          elevation: 2,
                          color: seen ? Colors.grey[200] : Colors.green[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    getNotificationIcon(type, seen),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notif['title'] ?? '',
                                            style: TextStyle(
                                              fontWeight: seen
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notif['body'] ?? '',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 12,
                                child: Text(
                                  timeAgo,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
