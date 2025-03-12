import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    _checkAuthStatus();
  }

  // Sign in with Twitch OAuth
  Future<void> signInWithTwitch() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.twitch,
        redirectTo: kIsWeb ? null : "io.supabase.flutter://callback",
        authScreenLaunchMode:
        kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      );
    } catch (error) {
      print("Erreur: $error");
      // You can show an alert to inform the user about the error
      _showErrorDialog(error.toString());
    }
  }

  // Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erreur d'authentification"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: signInWithTwitch,
          child: Text("Se connecter avec Twitch"),
        ),
      ),
    );
  }
}
