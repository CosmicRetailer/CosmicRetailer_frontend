import 'package:flutter/material.dart';

import '../auth.dart';
import '../routing.dart';
import '../screens/sign_in.dart';
import '../screens/main_screen.dart';
import '../screens/signup_screen.dart';
import '../widgets/fade_transition_page.dart';
import '../screens/scaffold.dart';

class BookstoreNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const BookstoreNavigator({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  State<BookstoreNavigator> createState() => _BookstoreNavigatorState();
}

class _BookstoreNavigatorState extends State<BookstoreNavigator> {
  final _signInKey = const ValueKey('Sign in');
  final _startKey = const ValueKey('Start screen');
  final _signUpKey = const ValueKey('Sign up');

  final _scaffoldKey = const ValueKey('App scaffold');
  final _bookDetailsKey = const ValueKey('Book details screen');
  final _authorDetailsKey = const ValueKey('Author details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = BookstoreAuthScope.of(context);

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, result) {
        if (route.settings is Page) {
          final page = route.settings as Page;
          if (page.key == _bookDetailsKey) {
            routeState.go('/books/popular');
          } else if (page.key == _authorDetailsKey) {
            routeState.go('/authors');
          }
        }
        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/signin')
          FadeTransitionPage<void>(
            key: _startKey,
            child: SignInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                  credentials.username,
                  credentials.password,
                );
                if (signedIn) {
                  await routeState.go('/books/popular');
                }
              },
            ),
          )
        else if (routeState.route.pathTemplate == '/main')
          FadeTransitionPage<void>(
            key: _signInKey,
            child: MainScreen(),
          )
        else if (routeState.route.pathTemplate == '/signup')
          FadeTransitionPage<void>(
            key: _signUpKey,
            child: SignUpScreen(
              onSignUp: (credentials) {
                // Tutaj możesz obsłużyć logikę rejestracji na podstawie dostarczonych danych
                print(
                    'Signed up with name: ${credentials.name}, email: ${credentials.email}, and password: ${credentials.password}');
              },
            ),
          )
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const BookstoreScaffold(),
          ),
          // Add an additional page to the stack if the user is viewing a book
          // or an author
          // if (selectedBook != null)
          //   MaterialPage<void>(
          //     key: _bookDetailsKey,
          //     child: BookDetailsScreen(
          //       book: selectedBook,
          //     ),
          //   )
          // else if (selectedAuthor != null)
          //   MaterialPage<void>(
          //     key: _authorDetailsKey,
          //     child: AuthorDetailsScreen(
          //       author: selectedAuthor,
          //     ),
          //   ),
        ],
      ],
    );
  }
}
