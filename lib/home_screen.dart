import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page contre l'IA (à créer)
                Navigator.pushNamed(context, '/game_ia');
              },
              child: Text('Jouer contre l\'IA'),
            ),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page de jeu local (à créer)
                Navigator.pushNamed(context, '/game_no_ia');
              },
              child: Text('Jouer en 1v1 local'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();

                // Attente de 500ms pour assurer que l'état a changé
                await Future.delayed(Duration(milliseconds: 500));

                // Naviguer vers la page de login
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Se déconnecter'),
            )
          ],
        ),
      ),
    );
  }
}
