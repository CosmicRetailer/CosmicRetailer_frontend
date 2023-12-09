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
    super.key,
    this.selectedIndex = 0,
    this.filteredItems, // Pass filtered items as a parameter
  });

  final int selectedIndex;
  final List<dynamic>? filteredItems; // Receive filtered items

  @override
  State<CosmicRetailerScaffold> createState() =>
      _CosmicRetailerScaffoldeState();
}

class _CosmicRetailerScaffoldeState extends State<CosmicRetailerScaffold> {
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

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    Notif.initialize(flutterLocalNotificationsPlugin);
    startPolling();

    // Initialize _widgetOptions based on whether filteredItems is provided
    if (widget.filteredItems != null) {
      _widgetOptions = [
        ItemListPage(items: widget.filteredItems!), // Pass filtered items
        const FavoriteItemsPage(),
        const Additem(),
        const UserProfilePage(),
      ];
    } else {
      _widgetOptions = [
        const ItemListPage(),
        const FavoriteItemsPage(),
        const Additem(),
        const UserProfilePage(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveNavigationScaffold(
        selectedIndex: widget.selectedIndex,
        body: _widgetOptions.elementAt(widget.selectedIndex),
        onDestinationSelected: (idx) {
          setState(() {
            _widgetOptions = [
              const ItemListPage(), // Reset ItemListPage to the default state
              const FavoriteItemsPage(),
              const Additem(),
              const UserProfilePage(),
            ];
          });

          // Handle additional logic based on the selected index if needed
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
