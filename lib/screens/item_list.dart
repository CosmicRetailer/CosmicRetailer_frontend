import 'package:flutter/material.dart';
import 'package:d_allegro/http_client.dart';
import 'product_page.dart';
import 'filtered_page.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({Key? key, this.items}) : super(key: key);

  final List<dynamic>? items;

  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  late Future<List<dynamic>?> itemsFuture;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    itemsFuture = fetchAllItems();
  }

  Future<List<dynamic>?> fetchAllItems() async {
    final response = await dio.get('$apiURL/all_items');

    if (response.statusCode == 200 && response.data['code'] == 200) {
      return response.data['items'];
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<List<dynamic>?> fetchItems(String searchQuery) async {
    final response = await dio.get('$apiURL/find/$searchQuery');

    if (response.statusCode == 200 && response.data['code'] == 200) {
      return response.data['items'];
    } else {
      throw Exception('Failed to load items');
    }
  }

  void onFilterPressed() async {
    final searchQuery = searchController.text;

    final filteredItems = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FilteredPage()),
    );

    if (filteredItems != null) {
      setState(() {
        itemsFuture = Future.value(filteredItems);
        searchController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CosmicRetailer'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () async {
                final searchQuery = searchController.text;
                setState(() {
                  if (searchQuery.isEmpty) {
                    itemsFuture = fetchAllItems();
                  } else {
                    itemsFuture = fetchItems(searchQuery);
                  }
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
                  onPressed: onFilterPressed,
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
                  labelText: 'Search for items',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: itemsFuture,
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

                        return Card(
                          margin: EdgeInsets.all(8),
                          child: InkWell(
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
                                  item['photoUrl'] ??
                                      'https://picsum.photos/200',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Text(
                                  title,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                Text(
                                  'Price: USDt ${price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
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
