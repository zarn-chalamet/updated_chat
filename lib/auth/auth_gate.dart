import 'package:app_chat/auth/login_or_signup.dart';
import 'package:app_chat/pages/top_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return TopNavBar(
              selectedIndex: 0,
            );
          } else {
            return const LoginOrSignUp();
          }
        },
      ),
    );
  }
}
