import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeter_app/main.dart';
import 'package:smartmeter_app/screens/auth.dart';
import '../../services/auth_services/auth_service.dart';
import '../../screens/auth.dart';
import '../../main.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleAuthService>(
      builder: (context, authService, _) {
        return StreamBuilder<User?>(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (snapshot.hasData) {
              // Utilisateur connecté
              return const MainScreen();
            } else {
              // Utilisateur non connecté
              return const AuthPage();
            }
          },
        );
      },
    );
  }
}