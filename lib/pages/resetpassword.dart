import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'resetpasswordverification.dart';

class ResetPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    try {
      final String email = emailController.text.trim();
      
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent! Check your inbox.'))
      );

      // Optionally, navigate to the verification page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerificationPage(email: email)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Enter your email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendPasswordResetEmail(context),
              child: Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}
