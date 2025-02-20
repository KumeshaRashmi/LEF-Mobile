import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lef_mob/pages/const.dart';
import 'package:lef_mob/pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';



void main() async {
  await _setup();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp()));
}

Future <void> _setup() async{
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventyfy',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const SplashPage(),  
    );
  }
}

