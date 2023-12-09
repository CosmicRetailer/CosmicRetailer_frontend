import 'package:dio/dio.dart';
import 'package:d_allegro/screens/rate_user.dart';
import 'package:flutter/material.dart';
import 'package:d_allegro/http_client.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    if (response.statusCode == 200 && response.data['code'] == 200) {
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

    if (response.statusCode == 200 &&
        context.mounted &&
        response.data['code'] == 200) {
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleFavorite() async {
    var itemID = widget.arguments.id;
    final response = await dio.put('$apiURL/toggle_favorite/$itemID');
    if (response.statusCode == 200 && response.data['code'] == 200) {
      setState(() {
        isFavorite = !isFavorite;
      });
    } else {
      throw Exception('Failed to update favorite status');
    }
  }

  void _buyItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var itemID = widget.arguments.id;
    print("privateKey: ${prefs.getString('privateKey')}");
    final response = await dio.post('$apiURL/buy_item/$itemID',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: {
          'privateKey': prefs.getString('privateKey'),
        });

    if (context.mounted &&
        response.data['code'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bought item', textAlign: TextAlign.center),
          backgroundColor: Colors.green,
        ),
      );
      // Navigator.pushReplacementNamed(context, '/main');
      Navigator.pop(context);
    } else if (context.mounted) {
      if (response.statusCode == 400 || response.data['code'] == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough money', textAlign: TextAlign.center),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to buy item', textAlign: TextAlign.center),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double widthFactor = 0.5;
    if (screenSize.width > 600) {
      widthFactor = 0.4;
    }
    if (screenSize.width > 1000) {
      widthFactor = 0.2;
    }

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
            return const Center(
                child: Text('Error: Unable to load item details'));
          } else {
            var item = snapshot.data?['item'];
            var user = snapshot.data?['user'];
            var isOwner = snapshot.data?['isOwner'];
            var nameToDisplay =
                user['fullName'] == null || user['fullName'] == ''
                    ? user['nickname']
                    : user['fullName'];
            var avgRating = user['rating_avg'] ?? 0;
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
                          InkWell(
                            child: RatingBarIndicator(
                              rating: avgRating.toDouble(),
                              itemSize: 15,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/rate',
                                  arguments: RateUserPageArguments(user['id']));
                            },
                          ),
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
                            onPressed: () {
                              _buyItem();
                            },
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
