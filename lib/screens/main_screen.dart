import 'package:flutter/material.dart';
import '../routing.dart'; // Zaimportuj plik routing.dart z odpowiednimi definicjami tras.

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My App Home Page'),
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
                primary: Colors.green,
                minimumSize: Size(200, 60),
              ),
              child: Text('Login',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                routeState.go('/signup');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                minimumSize: Size(200, 60),
              ),
              child: Text('Register',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
