import 'package:dio/dio.dart';
import 'package:lef_mob/pages/const.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._(); // Singleton instance creation

  static final StripeService instance = StripeService._();

  Future<void> makePayment(double totalPrice) async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(
      totalPrice.toInt(),
        "LKR"
        );
      if (paymentIntentClientSecret == null) return;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "LefMob",
        ),
      );
      await _processPayment();
      
    } catch (e) {
      print("Error in makePayment: $e");
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
          contentType :Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
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

  Future<void> _processPayment() async {
    try{
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();

    }catch(e){
      print(e);
    }
  }

  String _calculateAmount(int amount) {
    final calculateAmount = amount * 100;
    return calculateAmount.toString();
  }
}