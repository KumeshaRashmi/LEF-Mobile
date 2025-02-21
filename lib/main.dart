import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lef_mob/pages/splash.dart';
import 'package:device_preview/device_preview.dart';

// Function to handle background messages
@pragma('vm:entry-point') // Ensures this works in background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase
      .initializeApp(); // Ensure Firebase is initialized in the background
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures proper widget binding before initialization
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAWe6aFsLl75Iime5I1XIn7WslQZ-GigJ4",
      authDomain: "lef-mob.firebaseapp.com",
      projectId: "lef-mob",
      storageBucket: "lef-mob.firebasestorage.app",
      messagingSenderId: "425168014990",
      appId: "1:425168014990:web:e6402ff9d8e095065a83df",
      measurementId: "G-D6X71STK0T",
    ),
  );

  // Register the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp()); // Start the app after Firebase is initialized
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
      home: const SplashPage(), // Home screen of the app (SplashPage)
    );
  }
}
