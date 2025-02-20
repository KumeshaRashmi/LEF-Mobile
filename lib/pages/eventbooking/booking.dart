import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lef_mob/pages/services/stripe_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';


class BookingPage extends StatefulWidget {
  final Map<String, dynamic> event;
  const BookingPage({super.key, required this.event});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ticketsController = TextEditingController();
  String? _qrData;
  int _totalPrice = 0;

  void _calculateTotalPrice() {
    int ticketPrice = widget.event['price'] ?? 10; // Example event price
    int ticketCount = int.tryParse(_ticketsController.text) ?? 1;
    setState(() {
      _totalPrice = ticketPrice * ticketCount;
    });
  }

  void _confirmBooking() async {
    if (_formKey.currentState!.validate()) {
      _calculateTotalPrice();
      bool paymentSuccess = await StripeService.instance.makePayment(_totalPrice);

      if (paymentSuccess) {
        setState(() {
          _qrData = 'Name: ${_nameController.text}\n'
              'Phone: ${_phoneController.text}\n'
              'Tickets: ${_ticketsController.text}\n'
              'Event: ${widget.event['title']}';
        });

        // Generate and save QR Code
        String qrFilePath = await _generateQRCode();

        // Send Email and SMS
        _sendEmail(qrFilePath);
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    }
  }

  Future<String> _generateQRCode() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/ticket_qr.png';

      final qrImage = await QrPainter(
        data: _qrData!,
        version: QrVersions.auto,
        gapless: false,
      ).toImageData(200);

      final file = File(filePath);
      await file.writeAsBytes(qrImage!.buffer.asUint8List());

      return filePath;
    } catch (e) {
      print('QR Code Generation Failed: $e');
      return '';
    }
  }

  Future<void> _sendEmail(String qrFilePath) async {
    final Email email = Email(
      body: 'Thank you for booking your tickets! Your QR code is attached.',
      subject: 'Your Ticket QR Code',
      recipients: ['user@example.com'], // Replace with user's email
      attachmentPaths: [qrFilePath],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR code sent via email!')),
      );
    } catch (e) {
      print('Email Sending Failed: $e');
    }
  }

  // void _sendSMS(String qrFilePath) {
  //   String message = 'Thank you for booking! Download your QR code here: $qrFilePath';
  //   SmsSender sender = SmsSender();
  //   String recipient = _phoneController.text; // User's phone number

  //   SmsMessage sms = SmsMessage(recipient, message);
  //   sms.onStateChanged.listen((state) {
  //     if (state == SmsMessageState.Sent) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('QR code sent via SMS!')),
  //       );
  //     } else if (state == SmsMessageState.Fail) {
  //       print('Failed to send SMS');
  //     }
  //   });

  //   sender.sendSms(sms);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
              TextFormField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone')),
              TextFormField(
                controller: _ticketsController,
                decoration: InputDecoration(labelText: 'Tickets'),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotalPrice(),
              ),
              SizedBox(height: 20),
              Text('Total Price: \$$_totalPrice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _confirmBooking, child: Text('Confirm & Pay')),
            ],
          ),
        ),
      ),
    );
  }
}
