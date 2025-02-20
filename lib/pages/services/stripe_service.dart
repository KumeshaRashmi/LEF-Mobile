import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lef_mob/pages/const.dart'; // Ensure this file contains 'stripeSecretKey'

class StripeService {
  StripeService._(); // Singleton instance
  static final StripeService instance = StripeService._();

  Future<bool> makePayment(int totalAmount) async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(totalAmount, "usd");
      if (paymentIntentClientSecret == null) return false;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "LefMob",
        ),
      );

      return await _processPayment();
    } catch (e) {
      print("Error in makePayment: $e");
      return false;
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
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": "application/x-www-form-urlencoded"
          },
        ),
      );

      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      print("Error in _createPaymentIntent: $e");
      return null;
    }
  }

  Future<bool> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();
      return true;
    } catch (e) {
      print("Error in _processPayment: $e");
      return false;
    }
  }

  String _calculateAmount(int amount) {
    return (amount * 100).toString(); // Convert to cents
  }
}
