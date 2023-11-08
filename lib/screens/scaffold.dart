import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:d_allegro/screens/item_list.dart';
import 'package:d_allegro/screens/product_page.dart';
import 'package:flutter/material.dart';

class CosmicRetailerScaffold extends StatefulWidget {
  const CosmicRetailerScaffold({
    super.key,
  });
  @override
  State<CosmicRetailerScaffold> createState() =>
      _CosmicRetailerScaffoldeState();
}

class _CosmicRetailerScaffoldeState extends State<CosmicRetailerScaffold> {
  final List<Widget> _widgetOptions = [
    const Text('/favorites'),
    const DescriptionPage(itemID: '65458734f2f7683a6b22e5e6'),
    const ItemListPage()
  ];
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveNavigationScaffold(
        selectedIndex: _selectedIndex,
        body: _widgetOptions.elementAt(_selectedIndex),
        onDestinationSelected: (idx) {
          setState(() {
            _selectedIndex = idx;
          });
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
}
