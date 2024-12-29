// filepath: /c:/Users/Asus/Desktop/lef_mob/lib/pages/eventbooking/booking.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ticketsController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String _cardType = 'Visa';
  String? _qrData;
  final GlobalKey _qrKey = GlobalKey();

  void _confirmBooking() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _qrData = 'Name: ${_nameController.text}\n'
                  'Phone: ${_phoneController.text}\n'
                  'Tickets: ${_ticketsController.text}\n'
                  'Event: ${widget.event['title']}';
      });
    }
  }

  Future<void> _downloadQRCode() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/ticket.png');
      await file.writeAsBytes(pngBytes);

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text('Name: ${_nameController.text}'),
                pw.Text('Tickets: ${_ticketsController.text}'),
                pw.SizedBox(height: 16),
                pw.Image(pw.MemoryImage(pngBytes), width: 200, height: 200),
              ],
            );
          },
        ),
      );

      final pdfFile = File('${directory.path}/ticket.pdf');
      await pdfFile.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket saved as PNG and PDF in ${directory.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving ticket: $e')),
      );
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
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telephone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your telephone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ticketsController,
                decoration: const InputDecoration(labelText: 'Number of Tickets'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of tickets';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Card Payment Details', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _cardType,
                decoration: const InputDecoration(labelText: 'Card Type'),
                items: ['Visa', 'MasterCard', 'American Express'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _cardType = newValue!;
                  });
                },
              ),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expiry date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the CVV';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                  ),
                  child: const Text('Confirm Booking'),
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
                          data: _qrData!, // Positional argument for the data
                          version: QrVersions.auto, // Optional named parameter for the version
                          size: 200.0, // Optional named parameter for the size
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _downloadQRCode,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                        ),
                        child: const Text('Download QR Code'),
                      ),
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