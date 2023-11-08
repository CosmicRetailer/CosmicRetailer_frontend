import 'package:d_allegro/http_client.dart';
import 'package:flutter/material.dart';

class ItemListPage extends StatefulWidget {
  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  late Future<List<dynamic>?> items;
  TextEditingController searchController =
      TextEditingController(); // Kontroler pola wyszukiwania

  @override
  void initState() {
    super.initState();
    items = fetchItems();
  }

  Future<List<dynamic>?> fetchItems() async {
    final response = await dio.get('http://localhost:8080/all_items');

    if (response.statusCode == 200) {
      return response.data['items'];
    } else {
      throw Exception('Failed to load items');
    }
  }

  List<dynamic>? filterItemsWithNames(
      List<dynamic>? items, String searchQuery) {
    return items
        ?.where((item) =>
            item['name'] != null &&
            item['name']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista Przedmiotów'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {}); // Odśwież widok po zmianie pola wyszukiwania
              },
              decoration: InputDecoration(
                labelText: 'Szukaj przedmiotu...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: items,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final filteredItems = filterItemsWithNames(
                      snapshot.data, searchController.text);

                  if (filteredItems != null && filteredItems.isNotEmpty) {
                    return ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final imageUrl = item['photo'];
                        final title = item['name'];
                        final price = item['price'] != null
                            ? double.parse(item['price'].toString())
                            : 0.0;
                        return Column(
                          children: [
                            Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              title,
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              'Price: \$${price.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return Center(
                        child: Text('Brak przedmiotów o podanej nazwie.'));
                  }
                } else {
                  return Center(child: Text('Brak dostępnych przedmiotów.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
