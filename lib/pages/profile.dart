import 'package:flutter/material.dart';
import 'package:lef_mob/pages/favourites.dart';
import 'setting.dart';
import 'eventcalender.dart';

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
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.redAccent),
                  onPressed: () {
                    // Handle notification tap (e.g., open notifications page)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications tapped')),
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
                  buildMenuItem(context, 'Ticket Issues'),
                  buildMenuItem(context, 'Manage Events'),
                  buildMenuItem(context, 'Map'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
              // Navigate to Account Settings page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountSettingsPage(),
                ),
              );
            } else if (title == 'Calendar') {
              // Navigate to Event Calendar page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventCalendarPage(),
                ),
              );
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