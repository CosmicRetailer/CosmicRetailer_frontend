import 'package:flutter/material.dart';
import 'package:d_allegro/http_client.dart';
import 'product_page.dart'; // Import DescriptionPage

class ItemListPage extends StatefulWidget {
  const ItemListPage({Key? key});

  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  late Future<List<dynamic>?> items;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    items = Future.value(null);
  }

  Future<List<dynamic>?> fetchItems(String searchQuery) async {
    final response = await dio.get('$apiURL/find/$searchQuery');

    if (response.statusCode == 200) {
      return response.data['items'];
    } else {
      throw Exception('Failed to load items');
    }
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
                TextButton(
                  onPressed: () {
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
                Spacer(),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {},
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
                  final filteredItems = snapshot.data;

                  if (filteredItems != null && filteredItems.isNotEmpty) {
                    return ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final title = item['name'];
                        final price = item['price'] != null
                            ? double.parse(item['price'].toString())
                            : 0.0;

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DescriptionPage(
                                  arguments: ProductPageArguments(
                                    item[
                                        '_id'], // Assuming id is the unique identifier of the item
                                  ),
                                ),
                              ),
                            );
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
                    return const Center(child: Text('No items found.'));
                  }
                } else {
                  return const Center(child: Text('No items available.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
