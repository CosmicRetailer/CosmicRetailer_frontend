import 'package:d_allegro/screens/product_page.dart';
import 'package:flutter/material.dart';
import 'package:d_allegro/screens/item_list.dart';

import '../routing.dart';
import '../widgets/fade_transition_page.dart';
import 'scaffold.dart';

/// Displays the contents of the body of [CosmicRetailerScaffold]
class CosmicRetailerScaffoldBody extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const CosmicRetailerScaffoldBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var currentRoute = RouteStateScope.of(context).route;

    // A nested Router isn't necessary because the back button behavior doesn't
    // need to be customized.
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, dynamic result) => route.didPop(result),
      pages: [
        if (currentRoute.pathTemplate.startsWith('/favorites'))
          const FadeTransitionPage<void>(
            key: ValueKey('favorites'),
            child: Text('/favorites'),
          )
        else if (currentRoute.pathTemplate.startsWith('/settings'))
          const FadeTransitionPage<void>(
            key: ValueKey('settings'),
            child: DescriptionPage(itemID: '65458734f2f7683a6b22e5e6'),
          )
        else if (currentRoute.pathTemplate.startsWith('/items') ||
            currentRoute.pathTemplate == '/')
          FadeTransitionPage<void>(
            key: ValueKey('items'),
            child: ItemListPage(),
          )

        // Avoid building a Navigator with an empty `pages` list when the
        // RouteState is set to an unexpected path, such as /signin.
        //
        // Since RouteStateScope is an InheritedNotifier, any change to the
        // route will result in a call to this build method, even though this
        // widget isn't built when those routes are active.
        else
          FadeTransitionPage<void>(
            key: const ValueKey('empty'),
            child: Container(),
          ),
      ],
    );
  }
}
