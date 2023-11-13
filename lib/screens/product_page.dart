import 'package:flutter/material.dart';
import 'package:d_allegro/http_client.dart';

class ProductPageArguments {
  final String id;

  ProductPageArguments(this.id);
}

class DescriptionPage extends StatefulWidget {
  final ProductPageArguments arguments;

  const DescriptionPage({super.key, required this.arguments});

  @override
  State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  late Future<Map<String, dynamic>> itemDetails;
  bool isFavorite = false;
  @override
  void initState() {
    super.initState();
    itemDetails = fetchItemDetails(widget.arguments.id);
  }

  Future<Map<String, dynamic>> fetchItemDetails(String itemID) async {
    final response = await dio.get('$apiURL/get_item/$itemID');

    if (response.statusCode == 200) {
      setState(() {
        isFavorite = response.data?['isFavorite'];
      });
      return response.data;
    } else {
      throw Exception('Failed to load item details');
    }
  }

  void _deleteItem() async {
    var itemID = widget.arguments.id;
    final response = await dio.delete('$apiURL/delete_item/$itemID');

    if (response.statusCode == 200 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleted item', textAlign: TextAlign.center),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to deleted item', textAlign: TextAlign.center),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _toggleFavorite() async {
    var itemID = widget.arguments.id;
    final response = await dio.put('$apiURL/toggle_favorite/$itemID');
    if (response.statusCode == 200) {
      setState(() {
        isFavorite = !isFavorite; // Update favorite status
      });
    } else {
      throw Exception('Failed to update favorite status');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double widthFactor = screenSize.width > 600 ? 0.4 : 0.5;

    double padding = screenSize.width > 600 ? 20 : 12;

    double titleSize = screenSize.width > 600 ? 24 : 20;
    double priceSize = screenSize.width > 600 ? 28 : 24;
    double descriptionSize = screenSize.width > 600 ? 18 : 16;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Item Page',
            style: TextStyle(color: Colors.black, fontSize: titleSize)),
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
            var user = snapshot.data?['user'];
            var isOwner = snapshot.data?['isOwner'];
            var nameToDisplay =
                user['fullName'] == null || user['fullName'] == ''
                    ? user['nickname']
                    : user['fullName'];
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        item['photoUrl'] ?? 'https://picsum.photos/200',
                        width: screenSize.width * widthFactor,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return const Icon(Icons.image_not_supported,
                              size: 100.0);
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleSize,
                                ),
                              ),
                              isOwner == true
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                      ),
                                      onPressed: _deleteItem)
                                  : IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : null,
                                      ),
                                      onPressed: _toggleFavorite),
                            ],
                          ),
                          SizedBox(height: padding / 2),
                          Text(
                            'Owner: $nameToDisplay',
                            style: TextStyle(
                                fontSize: descriptionSize, color: Colors.grey),
                          ),
                          Text(
                            'Quantity: ${item['quantity']}',
                            style: TextStyle(
                                fontSize: descriptionSize, color: Colors.grey),
                          ),
                          SizedBox(height: padding),
                          Text(
                            '\$${item['price']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: priceSize),
                          ),
                          SizedBox(height: padding),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(screenSize.width * 0.3, 50),
                                backgroundColor: Colors.black),
                            child: const Text('BUY NOW'),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: padding),
                  Text(
                    "Description:",
                    style: TextStyle(
                        fontSize: descriptionSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: padding / 2),
                  Text(
                    item['description'],
                    style: TextStyle(fontSize: descriptionSize),
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
