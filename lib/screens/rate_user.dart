import 'package:d_allegro/auth.dart';
import 'package:d_allegro/http_client.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateUserPageArguments {
  final String id;

  RateUserPageArguments(this.id);
}

class RateUserPage extends StatefulWidget {
  final RateUserPageArguments arguments;
  const RateUserPage({Key? key, required this.arguments}) : super(key: key);

  @override
  State<RateUserPage> createState() => _RateUserPageState();
}

class _RateUserPageState extends State<RateUserPage> {
  Future<Map<String, dynamic>> fetchUserDetails(String userID) async {
    final response = await dio.get('$apiURL/get_user');

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load user details');
    }
  }

  final List<bool> _selectedButton = <bool>[true, false];
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double widthFactor = screenSize.width > 600 ? 0.4 : 0.5;

    double padding = screenSize.width > 600 ? 20 : 12;

    double titleSize = screenSize.width > 600 ? 24 : 20;
    double priceSize = screenSize.width > 600 ? 28 : 24;
    double descriptionSize = screenSize.width > 600 ? 18 : 16;
    final authState = CosmicRetailerAuthScope.of(context);
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

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text('Item Page',
                    style: TextStyle(color: Colors.black, fontSize: titleSize)),
                centerTitle: true,
                elevation: 1,
              ),
              body: SingleChildScrollView(
                child: Center(child: Text('User ID: ${widget.arguments.id}')),
              ),
            );
          }
        });
  }
}
