import 'package:d_allegro/screens/main_screen.dart';
import 'package:d_allegro/screens/sign_in.dart';
import 'package:d_allegro/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'http_client.dart';
import 'auth.dart';

class CosmicRetailer extends StatefulWidget {
  const CosmicRetailer({super.key});

  @override
  State<CosmicRetailer> createState() => _CosmicRetailerState();
}

void someFunction() {
  dio.get('/path').then((response) {
    // Use the response
  }).catchError((error) {
    // Handle the error
  });
}

class _CosmicRetailerState extends State<CosmicRetailer> {
  final _auth = CosmicRetailerAuth();

  @override
  void initState() {
    dioAuth = _auth;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CosmicRetailerAuthScope(notifier: _auth, child: const test());
  }
}

class test extends StatelessWidget {
  const test({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authState = CosmicRetailerAuthScope.of(context);
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(), // Główny ekran aplikacji
        '/signin': (context) => SignInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                  credentials.username,
                  credentials.password,
                  credentials.token,
                );
                if (signedIn && context.mounted) {
                  Navigator.pushNamed(context, '/items/all');
                }
              },
            ),
        '/signup': (context) => SignUpScreen(
              onSignUp: (credentials) {
                // Tutaj wyświetl alert
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Rejestracja'),
                      content: const Text('Pomyślna rejestracja.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Zamyka alert
                            Navigator.pushNamed(context, '/main');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        '/items/all': (context) => const MainScreen(),
      },
      theme: ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}
