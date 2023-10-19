import 'package:flutter/material.dart';

class LoginCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Text('Log In', style: TextStyle(fontSize: 20)),
          // Dodaj pola do wprowadzenia danych logowania
          // Dodaj przycisk "Log In" i odpowiednią logikę
        ],
      ),
    );
  }
}
