import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../routing.dart';

class Credentials {
  final String nickname;
  final String email;
  final String password;

  Credentials(this.nickname, this.email, this.password);
}

class SignUpScreen extends StatefulWidget {
  final ValueChanged<Credentials> onSignUp;

  const SignUpScreen({
    required this.onSignUp,
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            routeState.go('/main');
          },
        ),
        title: const Text('Sign up'),
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
                Text('Sign up',
                    style: Theme.of(context).textTheme.headlineMedium),
                TextField(
                  decoration: const InputDecoration(labelText: 'Nickname'),
                  controller: _nicknameController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  controller: _emailController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () {
                      final nickname = _nicknameController.text;
                      final email = _emailController.text;
                      final password = _passwordController.text;

                      final credentials =
                          Credentials(nickname, email, password);
                      widget.onSignUp(credentials);
                    },
                    child: const Text('Sign up'),
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

Future<void> registerUser(
    String nickname, String email, String password) async {
  final url = Uri.parse('http://127.0.0.1:8080/register');
  final response = await http.post(
    url,
    body: {
      'nickname': nickname,
      'email': email,
      'password': password,
    },
  );

  if (response.statusCode == 200) {
    // Pomyślna rejestracja
    // Tutaj można obsłużyć odpowiedź z backendu, jeśli jest dostępna
  } else {
    // Błąd rejestracji
    print('Błąd rejestracji: ${response.statusCode}');
  }
}
