import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lef_mob/pages/favourites.dart';
import 'setting.dart';
import 'eventcalender.dart';
import 'SettingsPage.dart';

class ProfilePage extends StatelessWidget {
  final String profileImageUrl;
  final String displayName;
  final String email;

  const ProfilePage({
    super.key,
    required this.profileImageUrl,
    required this.displayName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hide default AppBar
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Avatar and Notification Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : const AssetImage('lib/assets/profile.png')
                          as ImageProvider,
                ),
                // Notification Icon without Navigation to NotificationsPage
                StreamBuilder<int>(
                  stream: _getUnreadNotificationsCount(),
                  builder: (context, snapshot) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications,
                              color: Colors.redAccent),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notifications tapped'),
                              ),
                            );
                          },
                        ),
                        if (snapshot.hasData && snapshot.data! > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '${snapshot.data}', // Dynamic unread count
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Display Name and Email
            Text(
              displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Menu Options List
            Expanded(
              child: ListView(
                children: [
                  buildMenuItem(context, 'Account settings'),
                  buildMenuItem(context, 'Favorites'),
                  buildMenuItem(context, 'Calendar'),
                  buildMenuItem(context, 'Tickets Issued'),
                  buildMenuItem(context, 'Manage Events'),
                  buildMenuItem(context, 'Settings'),
                  buildMenuItem(context, 'Map'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stream to get unread notifications count
  Stream<int> _getUnreadNotificationsCount() {
    return FirebaseFirestore.instance
        .collection(
            'notifications') // Replace with your Firestore collection name
        .where('userId',
            isEqualTo: 'currentUserId') // Replace with actual user ID
        .where('isRead', isEqualTo: false) // Field for unread status
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Helper method to build a menu item with navigation handling
  Widget buildMenuItem(BuildContext context, String title) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            if (title == 'Account settings') {
              // Navigate to Account Settings page placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account settings tapped')),
              );
            } else if (title == 'Calendar') {
              // Navigate to Event Calendar page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventCalendarPage(),
                ),
              );
            } else if (title == 'Settings') {
              // Navigate to Settings page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
            } else if (title == 'Favorites') {
              // Navigate to Favorites page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            } else {
              // Handle other menu items (e.g., Map or Ticket Issues)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title tapped')),
              );
            }
          },
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }
}