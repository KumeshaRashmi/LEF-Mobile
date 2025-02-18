import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lef_mob/pages/creater/org_home.dart';
import 'package:lef_mob/pages/creater/org_signup.dart';


//import 'resetpassword.dart';

class OrgLoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  OrgLoginPage({super.key});

  Future<void> _signInWithEmail(BuildContext context) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    try {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

    // Fetch user details from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('organizers').doc(userCredential.user!.uid).get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrgHomePage(
            profileImageUrl: userData['profileImageUrl'] ?? '',
            displayName: userData['fullName'] ?? 'No Name',
            email: userData['email'] ?? 'No Email',
          ),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sign In failed: $e")),
    );
  }
}

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Initialize Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        // Authenticate with Firebase
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          // Navigate to Home page and pass user details
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrgHomePage(
                profileImageUrl: user.photoURL ?? '',
                displayName: user.displayName ?? 'No Name',
                email: user.email ?? 'No Email',
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Display error message if sign-in fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 240),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Welcome Back Creators!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 30),

              _buildTextField(
                controller: emailController,
                hintText: 'Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 15),

              _buildTextField(
                controller: passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 254, 93, 93),
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _signInWithEmail(context),
                child: const Text('Sign In', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),

              const SizedBox(height: 15),

              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Or', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 15),

              OutlinedButton.icon(
                icon: Image.asset('lib/assets/google.jpg', width: 24), 
                label: const Text(
                  'Continue with Google',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                onPressed: () => _signInWithGoogle(context),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrgSignupPage()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Color.fromARGB(255, 251, 87, 87), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}