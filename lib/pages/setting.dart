import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'login.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        fullNameController.text = data['fullName'] ?? '';
        phoneController.text = data['phone'] ?? '';
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage != null) {
      final fileName = 'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg';
      try {
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(_profileImage!);
        final downloadUrl = await ref.getDownloadURL();
        print('Image uploaded! URL: $downloadUrl');

        // Save image URL to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'profileImageUrl': downloadUrl,
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _saveUserData() async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'fullName': fullNameController.text.trim(),
          'phone': phoneController.text.trim(),
          // Include any other fields you need
        }, SetOptions(merge: true)); // Merge to update existing fields
        print('User data saved successfully');
      } catch (e) {
        print('Error saving user data: $e');
      }
    }
  }

  Future<void> _updatePassword() async {
    if (currentPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
      try {
        // Reauthenticate the user before updating the password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: currentPasswordController.text,
        );

        await user!.reauthenticateWithCredential(credential);
        await user!.updatePassword(newPasswordController.text);
        print('Password updated successfully');
      } catch (e) {
        print('Error updating password: $e');
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      print('User logged out successfully');
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
              backgroundColor: Colors.grey[300],
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _pickImage,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Update picture', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _uploadImage();
                await _saveUserData(); // Save user data after uploading image
              },
              child: const Text('Save Picture & Data'),
            ),
            const SizedBox(height: 30),
            buildAccountInfoRow('Full Name', fullNameController.text, true, fullNameController),
            buildAccountInfoRow('Email', user?.email ?? 'No Email', false, null),
            buildPasswordRow(),
          ],
        ),
      ),
    );
  }

  Widget buildAccountInfoRow(String label, String value, bool isEditable, TextEditingController? controller) {
    return Column(
      children: [
        ListTile(
          title: Text(label),
          subtitle: Text(value, style: const TextStyle(color: Colors.blue)),
          trailing: isEditable ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
          onTap: isEditable && controller != null
              ? () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Edit $label'),
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(hintText: 'Enter your $label'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                }
              : null,
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget buildPasswordRow() {
    return Column(
      children: [
        ListTile(
          title: const Text('Update Password'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Update Password'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: currentPasswordController,
                        decoration: const InputDecoration(hintText: 'Current Password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: newPasswordController,
                        decoration: const InputDecoration(hintText: 'New Password'),
                        obscureText: true,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _updatePassword();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }
}
