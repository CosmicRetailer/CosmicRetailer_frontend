import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BookstoreAuth(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
      ),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: Text('Log In', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(primary: Colors.green),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()));
              },
              child: Text('Sign Up', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(primary: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
                obscureText: !showPassword,
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Dodaj logikę dla "Forgot your password?"
              },
              child: Text(
                'Forgot your password?',
                style: TextStyle(
                  color: Colors.green,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Dodaj logikę logowania
                Provider.of<BookstoreAuth>(context, listen: false)
                    .setLoggedIn(true);
                Navigator.pop(context);
              },
              child: Text('Log In', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(primary: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool showPassword = false;
  bool agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
                obscureText: !showPassword,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Checkbox(
                  value: agreeToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      agreeToTerms = value!;
                    });
                  },
                ),
                Text(
                    'I would like to receive your newsletter and other promotional information.'),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Dodaj logikę rejestracji
                Provider.of<BookstoreAuth>(context, listen: false)
                    .setLoggedIn(true);
                Navigator.pop(context);
              },
              child: Text('Sign Up', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(primary: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class BookstoreAuth with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }
}
