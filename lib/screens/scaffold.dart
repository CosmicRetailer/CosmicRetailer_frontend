import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:d_allegro/screens/add_item.dart';
import 'package:d_allegro/screens/item_list.dart';
import 'package:d_allegro/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:d_allegro/screens/favorite_item.dart';

class CosmicRetailerScaffold extends StatefulWidget {
  const CosmicRetailerScaffold({
    Key? key,
    this.initialSelectedIndex = 0,
    this.filteredItems, // Pass filtered items as a parameter
  }) : super(key: key);

  final int initialSelectedIndex;
  final List<dynamic>? filteredItems; // Receive filtered items

  @override
  State<CosmicRetailerScaffold> createState() => _CosmicRetailerScaffoldState();
}

class _CosmicRetailerScaffoldState extends State<CosmicRetailerScaffold> {
  late int _selectedIndex;
  late Widget _currentPage;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
    _updateCurrentPage();
  }

  void _updateCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        _currentPage = widget.filteredItems != null
            ? ItemListPage(items: widget.filteredItems!)
            : const ItemListPage();
        break;
      case 1:
        _currentPage = const FavoriteItemsPage();
        break;
      case 2:
        _currentPage = const Additem();
        break;
      case 3:
        _currentPage = const UserProfilePage();
        break;
      default:
        throw ArgumentError("Invalid selectedIndex: $_selectedIndex");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveNavigationScaffold(
        selectedIndex: _selectedIndex,
        body: _currentPage,
        onDestinationSelected: (idx) {
          setState(() {
            _selectedIndex = idx;
            _updateCurrentPage();
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
            title: 'Add Item',
            icon: Icons.add,
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
