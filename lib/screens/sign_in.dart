import 'package:flutter/material.dart';
import '../routing.dart'; // Zaimportuj plik routing.dart z odpowiednimi definicjami tras.

class Credentials {
  final String username;
  final String password;

  Credentials(this.username, this.password);
}

class SignInScreen extends StatefulWidget {
  final ValueChanged<Credentials> onSignIn;

  const SignInScreen({
    required this.onSignIn,
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            routeState.go('/main');
          },
        ),
        title: Text('Sign In'),
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
                  decoration: const InputDecoration(labelText: 'Email'),
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
                      child: Text(
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
                    onPressed: () async {
                      widget.onSignIn(Credentials(
                          _usernameController.value.text,
                          _passwordController.value.text));
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
}
