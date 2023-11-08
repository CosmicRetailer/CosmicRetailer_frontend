import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DescriptionPage extends StatefulWidget {
  final String itemID;

  const DescriptionPage({super.key, required this.itemID});

  @override
  State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  late Future<Map<String, dynamic>> itemDetails;

  @override
  void initState() {
    super.initState();
    itemDetails = fetchItemDetails(widget.itemID);
  }

  Future<Map<String, dynamic>> fetchItemDetails(String itemID) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/get_item/$itemID'),
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjU0ODEzNGQ1ZGE2ZjliNjRjMDhhYmY2Iiwic3ViIjoiNjU0ODEzNGQ1ZGE2ZjliNjRjMDhhYmY2IiwiZXhwIjoxNjk5NDcyNDM0fQ.Jtu8I3zuIwor81cO6r1szxXGicNjreXmUhJtRIaEwO8',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load item details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text('Item Page', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 1,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: itemDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var item = snapshot.data?['item'];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            item['photo'],
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 16, width: 32),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                item['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Quantity: ${item['quantity']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '\$${item['price']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black),
                                child: const Text('BUY NOW'),
                              ),
                            ],
                          )
                        ]),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Description:",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
