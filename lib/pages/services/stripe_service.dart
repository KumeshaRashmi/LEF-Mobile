import 'package:dio/dio.dart';
import 'package:lef_mob/pages/const.dart';

class StripeService {
  StripeService._(); // Singleton instance creation

  static final StripeService instance = StripeService._();

  Future<void> makePayment() async {
    try {
      String? paymentIntent = await _createPaymentIntent(10, "usd");
      if (paymentIntent != null) {
        print("Payment Intent Created: $paymentIntent");
      }
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
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": "application/x-www-form-urlencoded"
          },
        ),
      );

      if (response.data != null) {
        print(response.data);
        return response.data['id'];
      }
      return null;
    } catch (e) {
      print("Error in _createPaymentIntent: $e");
      return null;
    }
  }

  String _calculateAmount(int amount) {
    final calculateAmount = amount * 100;
    return calculateAmount.toString();
  }
}
