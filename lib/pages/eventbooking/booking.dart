import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ticketsController = TextEditingController();
  final TextEditingController _cardHolderNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String _cardType = 'Visa';
  String? _qrData;
  final GlobalKey _qrKey = GlobalKey();

  double _ticketPrice = 0.0;
  int _numberOfTickets = 0;
  @override
  void initState() {
    super.initState();
    _ticketPrice = double.parse(widget.event['ticketPrice']);
  }

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
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telephone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
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
              const Text('Card Payment Details', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _cardType,
                decoration: const InputDecoration(
                  labelText: 'Card Type',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                items: ['Visa', 'MasterCard'].map((String value) {
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
                controller: _cardHolderNameController,
                decoration: const InputDecoration(
                  labelText: 'Card Holder Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the card holder name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryMonthController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Month (MM)',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the expiry month';
                        }
                        final month = int.tryParse(value);
                        if (month == null || month < 1 || month > 12) {
                          return 'Please enter a valid month';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _expiryYearController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Year (YY)',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the expiry year';
                        }
                        final year = int.tryParse(value);
                        if (year == null || year < 0 || year > 99) {
                          return 'Please enter a valid year';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: Icon(Icons.lock),
                ),
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
                  onPressed:(){
                    StripeService.instance.makePayment();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
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