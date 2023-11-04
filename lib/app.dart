import 'package:flutter/material.dart';

import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class CosmicRetailer extends StatefulWidget {
  const CosmicRetailer({super.key});

  @override
  State<CosmicRetailer> createState() => _CosmicRetailerState();
}

class _CosmicRetailerState extends State<CosmicRetailer> {
  final _auth = CosmicRetailerAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/main',
        '/signin',
        '/signup',
        '/settings',
        '/items/all',
        '/item/:itemId',
        '/favorites'
      ],
      guard: _guard,
      initialRoute: '/main',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => CosmicRetailerNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    // Listen for when the user logs out and display the signin screen.
    _auth.addListener(_handleAuthStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => RouteStateScope(
        notifier: _routeState,
        child: CosmicRetailerAuthScope(
          notifier: _auth,
          child: MaterialApp.router(
            routerDelegate: _routerDelegate,
            routeInformationParser: _routeParser,
            // Revert back to pre-Flutter-2.5 transition behavior:
            // https://github.com/flutter/flutter/issues/82053
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
          ),
        ),
      );

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = _auth.signedIn;
    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});
    final mainRoute = ParsedRoute('/main', '/main', {}, {});
    final signUpRoute = ParsedRoute('/signup', '/signup', {}, {});

    if (from == mainRoute && signedIn) {
      return ParsedRoute('/items/all', '/items/all', {}, {});
    } else if (!signedIn && from == signInRoute) {
      return signInRoute;
    } else if (!signedIn && from == signUpRoute) {
      return signUpRoute;
    } else if (signedIn && from == signInRoute) {
      return ParsedRoute('/items/all', '/items/all', {}, {});
    }
    return from;
  }

  void _handleAuthStateChanged() {
    if (!_auth.signedIn) {
      _routeState.go('/main');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }
}
