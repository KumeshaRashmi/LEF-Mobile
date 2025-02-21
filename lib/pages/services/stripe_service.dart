import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lef_mob/pages/const.dart';
import 'package:uuid/uuid.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  Future<String?> makePayment(String userId, double totalPrice) async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(
        totalPrice.toInt(),
        "LKR"
      );

      if (paymentIntentClientSecret == null) return null;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "LefMob",
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();

      // Generate a unique QR Code data
      String qrCodeData = _uuid.v4();

      // Store Payment Details in Firebase
      await _storePaymentDetails(userId, totalPrice, qrCodeData);

      return qrCodeData; // Return QR Code Data
    } catch (e) {
      print("Payment Failed: $e");
      return null;
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
      };

      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": " Bearer $stripeSecretKey",
            "Content-Type": "application/x-www-form-urlencoded"
          },
        ),
      );

      if (response.data != null) {
        print(response.data);
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      print("Error in _createPaymentIntent: $e");
      return null;
    }
  }

  Future<void> _storePaymentDetails(
      String userId, double amount, String qrCodeData) async {
    await _firestore.collection('users').doc(userId).collection('payment_status').add({
      'amount': amount,
      'status': 'successful',
      'timestamp': FieldValue.serverTimestamp(),
      'qr_code_data': qrCodeData,
    });
  }

  String _calculateAmount(int amount) {
    return (amount * 100).toString(); // Convert Rs. to cents
  }
}
