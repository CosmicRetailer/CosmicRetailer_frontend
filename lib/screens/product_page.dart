import 'package:flutter/material.dart';
import 'package:d_allegro/http_client.dart';

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
    final response = await dio.get('http://localhost:8080/get_item/$itemID');

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load item details');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery to get screen size
    Size screenSize = MediaQuery.of(context).size;
    double widthFactor = screenSize.width > 600
        ? 0.4
        : 0.5; // Example threshold for responsiveness

    // Responsive padding
    double padding = screenSize.width > 600 ? 24 : 16;

    // Responsive text sizes
    double titleSize = screenSize.width > 600 ? 24 : 20;
    double priceSize = screenSize.width > 600 ? 28 : 24;
    double descriptionSize = screenSize.width > 600 ? 18 : 16;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
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
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceAround,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: padding, // space between the children
                    children: [
                      Image.network(
                        item['photo'],
                        width: screenSize.width * widthFactor,
                        fit: BoxFit.cover,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: titleSize),
                          ),
                          SizedBox(height: padding / 2),
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
