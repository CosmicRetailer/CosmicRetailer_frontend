import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/all_items'),
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjU0ODEzNGQ1ZGE2ZjliNjRjMDhhYmY2Iiwic3ViIjoiNjU0ODEzNGQ1ZGE2ZjliNjRjMDhhYmY2IiwiZXhwIjoxNjk5NDcyNDM0fQ.Jtu8I3zuIwor81cO6r1szxXGicNjreXmUhJtRIaEwO8',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['items'];
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
