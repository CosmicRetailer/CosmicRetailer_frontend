import 'package:d_allegro/http_client.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Credentials {
  final String username;
  final String password;
  final String token;
  Credentials(this.username, this.password, this.token);
}

class SignInScreen extends StatefulWidget {
  final ValueChanged<Credentials> onSignIn;

  const SignInScreen({
    required this.onSignIn,
    Key? key,
  }) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> showLoginErrorDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Błąd logowania'),
          content:
              const Text('Wystąpił problem z logowaniem. Spróbuj ponownie.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamyka alert
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Card(
          child: Container(
            constraints: BoxConstraints.loose(const Size(600, 600)),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sign in',
                    style: Theme.of(context).textTheme.headlineMedium),
                TextField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  controller: _usernameController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: !_isPasswordVisible,
                  controller: _passwordController,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      child: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Tutaj możesz dodać logikę dla "Forgotten Password?"
                      },
                      child: const Text(
                        'Forgotten Password?',
                        style: TextStyle(
                          color: Colors.green,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () {
                      signInUser(
                        context,
                        _usernameController.text,
                        _passwordController.text,
                      );
                    },
                    child: const Text('Sign in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInUser(
      BuildContext context, String username, String password) async {
    final response = await http.post(Uri.parse('$apiURL/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nickname': username, 'password': password}));
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final token = responseBody['access_token'];
      final credentials = Credentials(username, password, token);
      widget.onSignIn(credentials);
    } else {
      if (context.mounted) {
        showLoginErrorDialog(context);
      } // Wyświetl alert o błędzie logowania
    }
  }
}
