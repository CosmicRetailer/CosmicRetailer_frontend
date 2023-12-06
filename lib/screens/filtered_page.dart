import 'package:flutter/material.dart';
import 'package:d_allegro/http_client.dart';
import 'scaffold.dart';

class FilteredPage extends StatefulWidget {
  @override
  _FilteredPageState createState() => _FilteredPageState();
}

class _FilteredPageState extends State<FilteredPage> {
  late TextEditingController searchController;
  double minPrice = 0.0;
  double maxPrice = 1000.0;
  bool usedCondition = false;
  bool newCondition = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  Future<void> onSearchPressed() async {
    final searchQuery = searchController.text;

    try {
      final response = await dio.get(
        searchQuery.isNotEmpty
            ? '$apiURL/find_tag/$searchQuery'
            : '$apiURL/all_items',
      );

      if (response.statusCode == 200) {
        List<dynamic>? items = response.data['items'];

        if (items != null && items.isNotEmpty) {
          final filteredItems = items.where((item) {
            final double price = double.parse(item['price'].toString());
            final roundedPrice = double.parse(price.toStringAsFixed(2));
            final String category = item['category'].toString().toLowerCase();

            final meetsPriceCriteria =
                roundedPrice >= minPrice && roundedPrice <= maxPrice;
            final meetsCategoryCriteria = (usedCondition && newCondition) ||
                (!usedCondition && !newCondition) ||
                (usedCondition && category.toLowerCase().contains('used')) ||
                (newCondition && category.toLowerCase().contains('new'));

            return meetsPriceCriteria && meetsCategoryCriteria;
          }).toList();

          Navigator.pop(context, filteredItems);
        } else {
          Navigator.pop(context, null);
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.data}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('Price Range'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Min: ${minPrice.toStringAsFixed(2)}'),
                Text('Max: ${maxPrice.toStringAsFixed(2)}'),
              ],
            ),
            RangeSlider(
              values: RangeValues(minPrice, maxPrice),
              onChanged: (values) {
                setState(() {
                  minPrice = values.start;
                  maxPrice = values.end;
                });
              },
              min: 0.0,
              max: 1000.0,
              divisions: 100,
              labels: RangeLabels(
                minPrice.toStringAsFixed(2),
                maxPrice.toStringAsFixed(2),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: usedCondition,
                  onChanged: (value) {
                    setState(() {
                      usedCondition = value ?? false;
                    });
                  },
                ),
                Text('Used'),
                SizedBox(width: 16),
                Checkbox(
                  value: newCondition,
                  onChanged: (value) {
                    setState(() {
                      newCondition = value ?? false;
                    });
                  },
                ),
                Text('New'),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async => await onSearchPressed(),
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
