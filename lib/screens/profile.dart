import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  final String userID;

  const UserProfilePage({Key? key, required this.userID}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String userName = '';
  String userProfilePicUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() {
    setState(() {
      userName = 'Victoria Robertson';
      userProfilePicUrl = 'https://picsum.photos/200';
    });
  }

  final List<bool> _selectedButton = <bool>[true, false];
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
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
            Navigator.pushNamed(context, '/settings');
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Handle logout tap
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
                radius: screenSize.width * 0.15,
                backgroundImage: NetworkImage(userProfilePicUrl),
              ),
              const SizedBox(height: 8),
              Text(
                userName,
                style: TextStyle(
                  fontSize: screenSize.width * 0.05,
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
                  minHeight: (screenSize.width * 0.10),
                  minWidth: (screenSize.width * 0.40),
                ),
                isSelected: _selectedButton,
                children: [
                  Text(
                    'My offers',
                    style: TextStyle(fontSize: screenSize.width * 0.04),
                  ),
                  Text('History',
                      style: TextStyle(fontSize: screenSize.width * 0.04))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
