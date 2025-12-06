import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  NotificationsPage({Key? key}) : super(key: key);

  // Sample uploaded plot dates
  final List<DateTime> uploadedPlots = [
    DateTime(2024, 3, 10),
    DateTime(2024, 7, 1),
  ];

  List<String> generateNotifications() {
    List<String> notifications = [];
    final now = DateTime.now();

    for (var uploadDate in uploadedPlots) {
      final firstNotification = uploadDate.add(const Duration(days: 365)); // after 1 year
      final secondNotification = uploadDate.add(const Duration(days: 365 + 180)); // 1 year + 6 months

      final dateFormat = DateFormat('dd MMM yyyy');

      if (firstNotification.isBefore(now)) {
        notifications.add("Time to monitor the plot (uploaded ${dateFormat.format(uploadDate)})");
      }

      if (secondNotification.isBefore(now)) {
        notifications.add("6-month follow-up for plot uploaded on ${dateFormat.format(uploadDate)}");
      }
    }

    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    final notifications = generateNotifications();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    leading: const Icon(Icons.notification_important, color: Colors.orange),
                    title: Text(notifications[index]),
                  ),
                );
              },
            ),
    );
  }
}
