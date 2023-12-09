import 'dart:io';

import 'package:d_allegro/http_client.dart';
import 'package:d_allegro/screens/import_wallet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  final String id;
  const SettingsPage({super.key, required this.id});

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  late Future<Map<String, dynamic>> currentSettings;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _addressController;
  late String imgUrl = '';
  late String _selectedCountry = 'Country 1';
  late String _walletAddress = '';

  final List<String> _countries = ['Country 1', 'Country 2', 'Country 3'];
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    currentSettings = fetchUserDetails(widget.id);
  }

  Future<Map<String, dynamic>> fetchUserDetails(String userID) async {
    final response = await dio.get('$apiURL/get_user');

    if (response.statusCode == 200 && response.data['code'] == 200) {
      var user = response.data?['user'];
      _fullNameController = TextEditingController(text: user['fullName']);
      _nicknameController = TextEditingController(text: user['nickname']);
      _emailController = TextEditingController(text: user['email']);
      _phoneNumberController = TextEditingController(text: user['phone']);
      _addressController = TextEditingController(text: user['address']);
      imgUrl = user['photoUrl'] ?? '';
      _selectedCountry = user['Country'] ?? 'Country 1';
      _walletAddress = user['walletAddress'] ?? '';
      return response.data;
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<Map<String, dynamic>> editSettings() async {
    var formData = FormData.fromMap({
      'fullName': _fullNameController.text,
      'nickname': _nicknameController.text,
      'email': _emailController.text,
      'country': _selectedCountry,
      'phone': _phoneNumberController.text,
      'address': _addressController.text,
      //'photo': 'photo',
      'photo':
          _image != null ? await MultipartFile.fromFile(_image!.path) : null,
    });
    final response = await dio.post('$apiURL/update_user', data: formData);

    if (response.statusCode == 200 && response.data['code'] == 200) {
      return response.data;
    } else {
      throw Exception('Failed to edit settings');
    }
  }

  Future<void> _submitSettings() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await editSettings();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings edited successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Failed to edit settings.', textAlign: TextAlign.center),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: _image != null
          ? Image.file(_image!, width: 100, height: 300, fit: BoxFit.contain)
          : Image.network(imgUrl, width: 100, height: 300, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        title: const Text('Settings',
            style: TextStyle(color: Colors.black, fontSize: 24)),
        centerTitle: true,
        elevation: 1,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: currentSettings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Form(
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
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
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
                    const Text(
                      'Wallet Address',
                      style: TextStyle(fontSize: 20),
                    ),
                    Row(
                      children: [
                        Text(
                          _walletAddress,
                          style: const TextStyle(fontSize: 12),
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _walletAddress),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImportWallet(),
                          ),
                        );
                      },
                      child: const Text(
                        'Change Wallet from Seed',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Profile Photo',
                      style: TextStyle(fontSize: 20),
                    ),
                    _image == null && imgUrl == ''
                        ? TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Add Photo'),
                          )
                        : _buildImagePicker(),
                    ElevatedButton(
                      onPressed: _submitSettings,
                      child: const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
