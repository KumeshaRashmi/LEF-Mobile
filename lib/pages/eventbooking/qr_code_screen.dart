import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeScreen extends StatelessWidget {
  final String qrCodeData;

  const QRCodeScreen({super.key, required this.qrCodeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Ticket QR Code")),
      body: Center(
        child: QrImageView(
          data: qrCodeData,
          version: QrVersions.auto,
          size: 250.0,
        ),
      ),
    );
  }
}
