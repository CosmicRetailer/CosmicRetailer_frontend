import 'dart:async';

import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:d_allegro/http_client.dart';
import 'package:d_allegro/screens/add_item.dart';
import 'package:d_allegro/screens/item_list.dart';
import 'package:d_allegro/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:d_allegro/screens/favorite_item.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:d_allegro/notification.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
  void startPolling() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      var response = await dio.get('$apiURL/get_notification');
      if (response.statusCode == 200 && response.data['code'] == 200) {
        var notification = response.data['notification'];
        showNotification(notification['_id'], notification['itemName']);
      }
    });
  }

  void showNotification(String id, String itemName) {
    var android = const AndroidNotificationDetails(
      'retailer',
      'Item sold',
      channelDescription: 'Your item has been sold!',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var iOS = const IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.show(
        1, 'Item Sold!', 'Your item $itemName has been sold!', platform);
  }

  late int _selectedIndex;
  late Widget _currentPage;

  @override
  void initState() {
    super.initState();
    Notif.initialize(flutterLocalNotificationsPlugin);
    startPolling();
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
