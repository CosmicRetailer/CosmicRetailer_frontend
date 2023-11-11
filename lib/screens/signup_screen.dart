import 'package:d_allegro/http_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future<void> showRegisterErrorDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Błąd rejestracji'),
          content:
              const Text('Wystąpił problem z rejestracją. Spróbuj ponownie.'),
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
                      registerUser(_nicknameController.text,
                          _emailController.text, _passwordController.text);
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

  Future<void> registerUser(
      String nickname, String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiURL/register'),
      body: {
        'email': email,
        'nickname': nickname,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final credentials = Credentials(nickname, email, password);
      widget.onSignUp(credentials);
    } else {
      if (context.mounted) {
        showRegisterErrorDialog(context);
      }
    }
  }
}
