import 'package:flutter/material.dart';
import 'package:d_allegro/http_client.dart';
import 'product_page.dart'; // Import DescriptionPage

class FavoriteItemsPage extends StatefulWidget {
  const FavoriteItemsPage({Key? key});

  @override
  _FavoriteItemsPageState createState() => _FavoriteItemsPageState();
}

class _FavoriteItemsPageState extends State<FavoriteItemsPage> {
  late Future<List<dynamic>?> favoriteItems;

  @override
  void initState() {
    super.initState();
    favoriteItems = fetchFavoriteItems();
  }

  Future<List<dynamic>?> fetchFavoriteItems() async {
    final response = await dio.get('$apiURL/get_favorites');

    if (response.statusCode == 200) {
      return response.data['favorites'];
    } else {
      throw Exception('Failed to load favorite items');
    }
  }

  // Metoda do odświeżania listy ulubionych
  Future<void> refreshFavoriteItems() async {
    final refreshedItems = await fetchFavoriteItems();
    setState(() {
      favoriteItems = Future.value(refreshedItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Ulubionych Przedmiotów'),
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: favoriteItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final favoriteItems = snapshot.data;

            if (favoriteItems != null && favoriteItems.isNotEmpty) {
              return ListView.builder(
                itemCount: favoriteItems.length,
                itemBuilder: (context, index) {
                  final item = favoriteItems[index];
                  final title = item['name'];
                  final price = item['price'] != null
                      ? double.parse(item['price'].toString())
                      : 0.0;

                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DescriptionPage(
                            arguments: ProductPageArguments(
                              item['_id'],
                            ),
                          ),
                        ),
                      );

                      refreshFavoriteItems();
                    },
                    child: Column(
                      children: [
                        Image.network(
                          item['photoUrl'] ?? 'https://picsum.photos/200',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          title,
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Price: \$${price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('No favorite items found.'));
            }
          } else {
            return const Center(child: Text('No favorite items available.'));
          }
        },
      ),
    );
  }
}
