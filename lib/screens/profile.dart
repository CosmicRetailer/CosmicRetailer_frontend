import 'package:d_allegro/auth.dart';
import 'package:d_allegro/http_client.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Future<Map<String, dynamic>> fetchUserDetails(String userID) async {
    final response = await dio.get('$apiURL/get_user');

    if (response.statusCode == 200 && response.data['code'] == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<List<dynamic>> fetchHistory(String userID) async {
    final response = await dio.get('$apiURL/get_history');

    if (response.statusCode == 200 && response.data['code'] == 200) {
      return response.data['history'];
    } else {
      throw Exception('Failed to load history');
    }
  }

  final List<bool> _selectedButton = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    final authState = CosmicRetailerAuthScope.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return FutureBuilder(
      future: fetchUserDetails(authState.userID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          var user = snapshot.data?['user'];
          var userName = (user['fullName'] == null || user['fullName'] == '')
              ? user['nickname']
              : user['fullName'];
          var userProfilePicUrl = user['photoUrl'] ?? '';
          var userItems = user['items'] ?? [];
          var history = user['items'] ?? [];

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text('Profile',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              centerTitle: true,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings')
                      .then((_) => setState(() {}));
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove('privateKey');
                    // TODO: Handle logout tap
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: screenSize.height * 0.05),
                    CircleAvatar(
                      radius:
                          (screenSize.width + screenSize.height) / 2 * 0.04 +
                              30,
                      backgroundImage: NetworkImage(userProfilePicUrl),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize:
                            (screenSize.width + screenSize.height) / 2 * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ToggleButtons(
                      direction: Axis.horizontal,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < _selectedButton.length; i++) {
                            _selectedButton[i] = i == index;
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedBorderColor: Colors.green[700],
                      selectedColor: Colors.white,
                      fillColor: Colors.green[200],
                      color: Colors.green[400],
                      constraints: BoxConstraints(
                        minHeight: (screenSize.width * 0.05) + 30,
                        minWidth: (screenSize.width * 0.20 + 60),
                        maxWidth: (screenSize.width * 0.40),
                      ),
                      isSelected: _selectedButton,
                      children: [
                        Text(
                          'My offers',
                          style:
                              TextStyle(fontSize: screenSize.width * 0.04 + 4),
                        ),
                        Text('History',
                            style: TextStyle(
                                fontSize: screenSize.width * 0.04 + 4)),
                      ],
                    ),
                    if (_selectedButton[0]) // Display user offers
                      Column(
                        children: userItems.map<Widget>((item) {
                          return Card(
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(item['name']),
                              subtitle: Text(
                                'Price: \$${item['price']} | Quantity: ${item['quantity']}',
                              ),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      item['photoUrl'] ??
                                          'https://picsum.photos/200',
                                    ),
                                  ),
                                ),
                              ),
                              // Add more details as needed
                            ),
                          );
                        }).toList(),
                      ),
                    if (_selectedButton[1]) // Display history
                      Column(
                        children: [
                          FutureBuilder(
                            future: fetchHistory(authState.userID),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                var history = snapshot.data ?? [];

                                return Column(
                                  children: history.map<Widget>((item) {
                                    return Card(
                                      margin: EdgeInsets.all(8),
                                      child: ListTile(
                                        title: Text(item['itemName'] ?? ''),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Price: \$${item['price'] ?? ''}'),
                                            Text('Type: ${item['type'] ?? ''}'),
                                            // Dodaj inne informacje historyczne, jeśli są dostępne
                                          ],
                                        ),
                                        leading: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                item['photoUrl'] ??
                                                    'https://picsum.photos/200',
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Dodaj więcej szczegółów, jeśli są dostępne
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                        // children: history.map<Widget>((item) {
                        //   return Card(
                        //     margin: EdgeInsets.all(8),
                        //     child: ListTile(
                        //       title: Text(item['itemName'] ?? ''),
                        //       subtitle: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Text('Price: \$${item['price'] ?? ''}'),
                        //           Text('Type: ${item['type'] ?? ''}'),
                        //           // Dodaj inne informacje historyczne, jeśli są dostępne
                        //         ],
                        //       ),
                        //       leading: Container(
                        //         width: 60,
                        //         height: 60,
                        //         decoration: BoxDecoration(
                        //           shape: BoxShape.circle,
                        //           image: DecorationImage(
                        //             fit: BoxFit.cover,
                        //             image: NetworkImage(
                        //               item['photoUrl'] ??
                        //                   'https://picsum.photos/200',
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       // Dodaj więcej szczegółów, jeśli są dostępne
                        //     ),
                        //   );
                        // }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
