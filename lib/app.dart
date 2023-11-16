import 'package:d_allegro/screens/main_screen.dart';
import 'package:d_allegro/screens/product_page.dart';
import 'package:d_allegro/screens/scaffold.dart';
import 'package:d_allegro/screens/settings.dart';
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

class _CosmicRetailerState extends State<CosmicRetailer> {
  final _auth = CosmicRetailerAuth();

  @override
  void initState() {
    dioAuth = _auth;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CosmicRetailerAuthScope(
        notifier: _auth, child: const CosmicRetailerApp());
  }
}

class CosmicRetailerApp extends StatelessWidget {
  const CosmicRetailerApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authState = CosmicRetailerAuthScope.of(context);
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/signin': (context) => SignInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                  credentials.username,
                  credentials.password,
                  credentials.token,
                );
                if (signedIn && context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/main');
                }
              },
            ),
        '/signup': (context) => SignUpScreen(
              onSignUp: (credentials) async {
                var signedUp = await authState.signUp(
                  credentials.nickname,
                  credentials.email,
                  credentials.password,
                  credentials.token,
                );
                if (signedUp && context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Register successful'),
                        content: const Text('You have been registered!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacementNamed(context, '/main');
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
        '/main': (context) => const CosmicRetailerScaffold(),
        '/settings': (context) => SettingsPage(id: authState.userID),
        '/item': (context) => DescriptionPage(
            arguments: ModalRoute.of(context)!.settings.arguments
                as ProductPageArguments),
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
