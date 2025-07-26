import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/authentication/login_screen.dart'; // We will create this later

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen(); // Navigate to HomeScreen if user is logged in
        } else {
          return const LoginScreen(); // Navigate to LoginScreen if user is not logged in
        }
      },
    );
  }
}