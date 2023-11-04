import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:flutter/material.dart';

import '../routing.dart';
import 'scaffold_body.dart';

class CosmicRetailerScaffold extends StatelessWidget {
  const CosmicRetailerScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final selectedIndex = _getSelectedIndex(routeState.route.pathTemplate);

    return Scaffold(
      body: AdaptiveNavigationScaffold(
        selectedIndex: selectedIndex,
        body: const CosmicRetailerScaffoldBody(),
        onDestinationSelected: (idx) {
          if (idx == 0) routeState.go('/items/all');
          if (idx == 1) routeState.go('/favorites');
          if (idx == 2) routeState.go('/settings');
        },
        destinations: const [
          AdaptiveScaffoldDestination(
            title: 'Items',
            icon: Icons.home,
          ),
          AdaptiveScaffoldDestination(
            title: 'Favorites',
            icon: Icons.favorite,
          ),
          AdaptiveScaffoldDestination(
            title: 'Settings',
            icon: Icons.settings,
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String pathTemplate) {
    if (pathTemplate.startsWith('/items')) return 0;
    if (pathTemplate == '/favorites') return 1;
    if (pathTemplate == '/settings') return 2;
    return 0;
  }
}
