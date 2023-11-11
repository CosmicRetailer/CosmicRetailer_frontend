import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  late Future<Map<String, dynamic>> currentSettings;
  final _formKey = GlobalKey<FormState>();

  // Define controllers for each form field
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedCountry = 'Country 1'; // Default value

  // Dummy list of countries for the dropdown
  final List<String> _countries = ['Country 1', 'Country 2', 'Country 3'];

  Future<Map<String, dynamic>?> editSettings() async {
    //todo call to backend
    return null;
    // if (response.statusCode == 200) {
    //   return response.data;
    // } else {
    //   throw Exception('Failed to edit settings');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Settings',
            style: TextStyle(color: Colors.black, fontSize: 24)),
        centerTitle: true,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: 'Nickname'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            DropdownButtonFormField(
              value: _selectedCountry,
              items: _countries.map((String country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountry = newValue!;
                });
              },
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  editSettings();
                }
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    _fullNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
