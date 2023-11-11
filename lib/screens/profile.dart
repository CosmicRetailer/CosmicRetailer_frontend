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
    // Replace this with your actual data fetching logic
    setState(() {
      userName = 'Victoria Robertson'; // Dummy data
      userProfilePicUrl = 'https://picsum.photos/200'; // Dummy URL
    });
  }

  final List<bool> _selectedButton = <bool>[true, false];
  @override
  Widget build(BuildContext context) {
    // Determine the screen size
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
      body: Center(
        // Center widget to center the Column
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Center the content vertically
          children: <Widget>[
            SizedBox(height: screenSize.height * 0.05), // Responsive spacing
            CircleAvatar(
              radius: screenSize.width * 0.15, // Responsive radius
              backgroundImage: NetworkImage(userProfilePicUrl),
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: TextStyle(
                fontSize: screenSize.width * 0.05, // Responsive font size
                fontWeight: FontWeight.bold,
              ),
            ),
            ToggleButtons(
              direction: Axis.horizontal,
              onPressed: (int index) {
                setState(() {
                  // The button that is tapped is set to true, and the others to false.
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
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 160.0,
              ),
              isSelected: _selectedButton,
              children: const [Text('My offers'), Text('History')],
            ),
          ],
        ),
      ),
    );
  }
}
