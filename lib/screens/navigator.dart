import 'package:flutter/material.dart';

import '../auth.dart';
import '../routing.dart';
import '../screens/sign_in.dart';
import '../screens/main_screen.dart';
import '../screens/signup_screen.dart';
import '../widgets/fade_transition_page.dart';
import '../screens/scaffold.dart';

class CosmicRetailerNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const CosmicRetailerNavigator({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  State<CosmicRetailerNavigator> createState() =>
      _CosmicRetailerNavigatorState();
}

class _CosmicRetailerNavigatorState extends State<CosmicRetailerNavigator> {
  final _signInKey = const ValueKey('Sign in');
  final _startKey = const ValueKey('Start screen');
  final _signUpKey = const ValueKey('Sign up');

  final _scaffoldKey = const ValueKey('App scaffold');
  final _itemDetailsKey = const ValueKey('Item details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = CosmicRetailerAuthScope.of(context);

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, result) {
        if (route.settings is Page) {
          final page = route.settings as Page;
          if (page.key == _itemDetailsKey) {
            routeState.go('/items/all');
          }
        }
        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/signin')
          FadeTransitionPage<void>(
            key: _signInKey,
            child: SignInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                  credentials.username,
                  credentials.password,
                  credentials.token,
                );
                if (signedIn) {
                  routeState.go('/items/all');
                }
              },
            ),
          )
        else if (routeState.route.pathTemplate == '/main')
          FadeTransitionPage<void>(
            key: _startKey,
            child: const MainScreen(),
          )
        else if (routeState.route.pathTemplate == '/signup')
          FadeTransitionPage<void>(
            key: _signUpKey,
            child: SignUpScreen(
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
                            routeState.go('/main');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const CosmicRetailerScaffold(),
          ),
          // Add an additional page to the stack if the user is viewing a item
          // if (selectedItem!= null)
          //   MaterialPage<void>(
          //     key: _itemDetailsKey,
          //     child: ItemDetailsScreen(
          //       Item: selectedItem,
          //     ),
          //   )
        ],
      ],
    );
  }
}
