import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationsPage extends StatefulWidget {
  const PushNotificationsPage({Key? key}) : super(key: key);

  @override
  _PushNotificationsPageState createState() => _PushNotificationsPageState();
}

class _PushNotificationsPageState extends State<PushNotificationsPage> {
  // Notification toggles
  bool likedEvents = false;
  bool reminders = false;
  bool recommendations = false;
  bool purchasedTickets = false;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
    _loadNotificationPreferences();
  }

  // Initialize Firebase Cloud Messaging
  void _initializeFCM() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the FCM token
    await getToken();

    // Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print(
            "Foreground notification received: ${message.notification?.title}");
        _showNotificationDialog(
            message.notification?.title, message.notification?.body);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when a user taps on a notification
      print("Notification opened: ${message.notification?.title}");
    });
  }

  // Get the FCM token
  Future<void> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
  }

  // Load notification preferences (fetch from Firestore or local storage)
  void _loadNotificationPreferences() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc('currentUserId') // Replace with the actual user ID
        .get();

    if (doc.exists) {
      final data = doc.data();
      setState(() {
        likedEvents = data?['likedEvents'] ?? false;
        reminders = data?['reminders'] ?? false;
        recommendations = data?['recommendations'] ?? false;
        purchasedTickets = data?['purchasedTickets'] ?? false;
      });
    }
  }

  // Save notification preferences
  void _saveNotificationPreferences() {
    FirebaseFirestore.instance
        .collection('users')
        .doc('currentUserId') // Replace with the actual user ID
        .set({
      'likedEvents': likedEvents,
      'reminders': reminders,
      'recommendations': recommendations,
      'purchasedTickets': purchasedTickets,
    }, SetOptions(merge: true));

    // Trigger specific notifications based on toggles
    _sendNotificationForToggles();
  }

  // Handle toggle changes and save to Firestore
  void _onToggleChanged(String key, bool value) {
    setState(() {
      if (key == 'likedEvents') likedEvents = value;
      if (key == 'reminders') reminders = value;
      if (key == 'recommendations') recommendations = value;
      if (key == 'purchasedTickets') purchasedTickets = value;
    });
    _saveNotificationPreferences();
  }

  // Send notifications based on toggle states
  void _sendNotificationForToggles() {
    if (likedEvents) {
      _sendNotification(
          "Liked Events", "Stay updated with alerts for your favorite events.");
    }
    if (reminders) {
      _sendNotification(
          "Reminders", "Don't forget to check out the latest events!");
    }
    if (recommendations) {
      _sendNotification(
          "Recommendations", "Explore events tailored to your preferences!");
    }
    if (purchasedTickets) {
      _sendNotification("Purchased Tickets",
          "Your tickets have been successfully delivered.");
    }
  }

  // Send a push notification
  void _sendNotification(String title, String body) {
    _firebaseMessaging.subscribeToTopic(
        "global"); // Example: Use topics for group notifications
    print("Notification sent: $title - $body");
    // Implement your server-side logic to trigger the notification using Firebase Admin SDK
  }

  // Show a notification dialog when receiving a foreground message
  void _showNotificationDialog(String? title, String? body) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title ?? "No Title"),
          content: Text(body ?? "No Body"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationOption(
              title: "Liked events",
              description:
                  "Stay informed with alerts when your preferred events are coming up.",
              value: likedEvents,
              onChanged: (value) => _onToggleChanged('likedEvents', value),
            ),
            _divider(),
            _buildNotificationOption(
              title: "Reminders",
              description:
                  "Enable notifications to remind you when events become available before one day.",
              value: reminders,
              onChanged: (value) => _onToggleChanged('reminders', value),
            ),
            _divider(),
            _buildNotificationOption(
              title: "Recommendations",
              description:
                  "Get recommended events based on your interests and location.",
              value: recommendations,
              onChanged: (value) => _onToggleChanged('recommendations', value),
            ),
            _divider(),
            _buildNotificationOption(
              title: "Purchased tickets",
              description:
                  "Know when tickets are delivered and your events are about to start.",
              value: purchasedTickets,
              onChanged: (value) => _onToggleChanged('purchasedTickets', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(
        thickness: 1.0,
        color: Colors.grey[300],
      ),
    );
  }
}
