import 'package:flutter_email_sender/flutter_email_sender.dart';

class EmailService {
  static Future<void> sendEmail(String recipient, String qrCodeLink) async {
    final Email email = Email(
      body: 'Here is your QR code link for your ticket: $qrCodeLink',
      subject: 'Your Ticket Confirmation',
      recipients: [recipient],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print('Failed to send email: $error');
    }
  }
}
