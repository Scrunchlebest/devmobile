import 'package:cheese/game_without_ia_sceen.dart';
import 'package:flutter/material.dart';
import 'package:cheese/game_with_ia_screen.dart';
import 'package:cheese/home_screen.dart';
import 'package:cheese/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zupupuxlfysmjbcsuuky.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp1cHVwdXhsZnlzbWpiY3N1dWt5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE2Nzc2NDQsImV4cCI6MjA1NzI1MzY0NH0.4T1rZg3RwG67fsKq5e-sWOo8ITmC4K_j9bno7lXOVWQ',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cheese',
        theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        ),
        initialRoute: session != null ? '/home' : '/login',//
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/game_ia' : (context) => GameIA(),
          '/game_no_ia' : (context) => GameNoIA(),
      }
    );
  }
}