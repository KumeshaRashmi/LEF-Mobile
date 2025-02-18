import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'push_notifications.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user's email from Firebase Authentication
    final User? user = FirebaseAuth.instance.currentUser;
    final String userEmail =
        user?.email ?? 'Not logged in'; // Default if not logged in

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SectionHeader(title: 'Account'),
          buildMenuItem(
            context,
            title: 'Push Notifications',
            onTap: () {
              // Navigate to Push Notifications Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PushNotificationsPage(),
                ),
              );
            },
          ),
          buildMenuItem(
            context,
            title: 'Facebook',
            onTap: () {
              // Handle Facebook navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Facebook tapped')),
              );
            },
          ),
          const SectionHeader(title: 'About'),
          buildMenuItem(
            context,
            title: 'Rate Us',
            onTap: () {
              // Handle Rate Us navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rate Us tapped')),
              );
            },
          ),
          buildMenuItem(
            context,
            title: 'Suggest Improvement',
            onTap: () {
              // Handle Suggest Improvement navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Suggest Improvement tapped')),
              );
            },
          ),
          buildMenuItem(
            context,
            title: 'Legal',
            onTap: () {
              // Handle Legal navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Legal tapped')),
              );
            },
          ),
          buildMenuItem(
            context,
            title: 'How to use the app',
            onTap: () {
              // Handle How to use the app navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('How to use the app tapped')),
              );
            },
          ),
          buildMenuItem(
            context,
            title: 'Acknowledgements',
            onTap: () {
              // Handle Acknowledgements navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Acknowledgements tapped')),
              );
            },
          ),
          const SectionHeader(title: 'Profile'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              userEmail, // Display dynamic email address
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
