import 'package:flutter/material.dart';
import '../routing.dart'; // Zaimportuj plik routing.dart z odpowiednimi definicjami tras.

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My App Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                routeState.go('/signin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(200, 60),
              ),
              child: const Text('Login',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                routeState.go('/signup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(200, 60),
              ),
              child: const Text('Register',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
