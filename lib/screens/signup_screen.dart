import 'package:flutter/material.dart';
import '../routing.dart'; // Zaimportuj plik routing.dart z odpowiednimi definicjami tras.

class Credentials {
  final String name;
  final String email;
  final String password;

  Credentials(this.name, this.email, this.password);
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
        title: Text('Sign up'),
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
                  decoration: const InputDecoration(labelText: 'Name'),
                  controller: _nameController,
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
                      // final credentials = Credentials(
                      //   _nameController.value.text,
                      //   _emailController.value.text,
                      //   _passwordController.value.text,
                      // );
                      // widget.onSignUp(credentials);
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
