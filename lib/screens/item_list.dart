import 'package:d_allegro/http_client.dart';
import 'package:flutter/material.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  late Future<List<dynamic>?> items;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicjalizacja Future bez pobierania danych, bo chcemy to zrobić po naciśnięciu przycisku Search
    items = Future.value(null);
  }

  Future<List<dynamic>?> fetchItems(String searchQuery) async {
    final response = await dio.get('$apiURL/all_items?q=$searchQuery');

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
        title: const Text('Lista Przedmiotów'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () async {
                // Implement search functionality
                // Pobierz dane dopiero po naciśnięciu przycisku Search
                final searchQuery = searchController.text;
                final fetchedItems = await fetchItems(searchQuery);
                setState(() {
                  items = Future.value(fetchedItems);
                });
              },
              child: Text(
                'Search',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Left side Filter
                TextButton(
                  onPressed: () {
                    // Implement filter functionality
                    // Możesz dodać kod obsługujący filtrowanie
                    // na przykład otwierając okno dialogowe z opcjami filtrowania.
                    print('Filter pressed');
                  },
                  child: Row(
                    children: [
                      Icon(Icons.filter_list),
                      SizedBox(width: 8),
                      Text(
                        'Filter',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Spacer(), // Spacer to push Search to the right
                // Right side Search
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  // Nie potrzebujemy setState w tej funkcji
                },
                decoration: const InputDecoration(
                  labelText: 'Szukaj przedmiotu...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: items,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              'Price: \$${price.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return const Center(
                        child: Text('Brak przedmiotów o podanej nazwie.'));
                  }
                } else {
                  return const Center(
                      child: Text('Brak dostępnych przedmiotów.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
