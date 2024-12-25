import 'package:flutter/material.dart';
import 'newpassword.dart';

class VerificationPage extends StatelessWidget {
  final TextEditingController codeController = TextEditingController();
  final String email;

  VerificationPage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(labelText: 'Enter verification code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewPasswordPage(email: email)),
                );
              },
              child: Text('Verify and Proceed'),
            ),
          ],
        ),
      ),
    );
  }
}
