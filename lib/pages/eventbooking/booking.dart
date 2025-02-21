//import 'dart:io';
//import 'dart:typed_data';
//import 'dart:ui';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lef_mob/pages/eventbooking/qr_code_screen.dart';
import 'package:lef_mob/pages/services/stripe_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const BookingPage({Key? key, required this.event}) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ticketsController = TextEditingController();
  String _selectedCountryCode = '+94';
  String? _qrData;
  final GlobalKey _qrKey = GlobalKey();

  double _ticketPrice = 0.0;
  int _numberOfTickets = 0;

  @override
  void initState() {
    super.initState();
    _ticketPrice = double.parse(widget.event['ticketPrice']);
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  void _confirmBooking() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _qrData = 'Name: ${_nameController.text}\n'
            'Email: ${_emailController.text}\n'
            'Phone: $_selectedCountryCode ${_phoneController.text}\n'
            'Tickets: ${_ticketsController.text}\n'
            'Event: ${widget.event['title']}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Tickets for ${widget.event['title']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                readOnly: true, // Auto-filled from Firebase
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                readOnly: true, // Auto-filled from Firebase
              ),
              Row(
                children: [
                  CountryCodePicker(
                    onChanged: (code) {
                      setState(() {
                        _selectedCountryCode = code.dialCode!;
                      });
                    },
                    initialSelection: 'LK',
                    favorite: ['+94', 'US', 'IN'],
                    showFlag: true,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _ticketsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Tickets',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of tickets';
                  }
                  final ticketCount = int.tryParse(value);
                  if (ticketCount == null || ticketCount <= 0) {
                    return 'Please enter a valid number of tickets';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _numberOfTickets = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_numberOfTickets > 0)
                Text(
                  'Total Price: Rs. ${(_numberOfTickets * _ticketPrice).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    double totalPrice = _numberOfTickets * _ticketPrice;
                    String userId = "example_user_id"; // Get from Auth
                    String? qrCodeData = await StripeService.instance.makePayment(userId, totalPrice);

                    if (qrCodeData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCodeScreen(qrCodeData: qrCodeData),
                        ),
                      );
                    }
                  }
                },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Proceed to Payment'),
                ),
              ),
              const SizedBox(height: 16),
              if (_qrData != null)
                Center(
                  child: Column(
                    children: [
                      const Text('Your Ticket QR Code:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      RepaintBoundary(
                        key: _qrKey,
                        child: QrImageView(
                          data: _qrData!,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
