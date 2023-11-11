import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:d_allegro/http_client.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class Additem extends StatefulWidget {
  const Additem({
    super.key,
  });

  @override
  State<Additem> createState() => _AdditemState();
}

class _AdditemState extends State<Additem> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  String? _category;
  File? _image;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      onTap: _pickImage, // Call the same function to change the image
      child: _image != null
          ? Image.file(_image!, width: 100, height: 300, fit: BoxFit.fitHeight)
          : const Icon(Icons.camera_alt, size: 100.0),
    );
  }

  Future<void> _submitItem() async {
    if (_formKey.currentState!.validate()) {
      // You might want to include the image and other details in your request
      try {
        final response = await addItem();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add item', textAlign: TextAlign.center),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<Map<String, dynamic>> addItem() async {
    // Assuming `dio` is a global instance of Dio
    final response = await dio.post(
      '$apiURL/add_item',
      data: FormData.fromMap({
        'name': _nameController.text,
        'price': _priceController.text,
        'quantity': _quantityController.text,
        'description': _descriptionController.text,
        'category': _category,
        // The image handling depends on your API
        'photo':
            _image != null ? await MultipartFile.fromFile(_image!.path) : null,
      }),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to add item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Add Item',
            style: TextStyle(color: Colors.black, fontSize: 24)),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              ListTile(
                title: const Text('New'),
                leading: Radio<String>(
                  value: 'new',
                  groupValue: _category,
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Used'),
                leading: Radio<String>(
                  value: 'used',
                  groupValue: _category,
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                    });
                  },
                ),
              ),
              _image != null
                  ? _buildImagePicker()
                  : TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Photo'),
                    ),
              ElevatedButton(
                onPressed: _submitItem,
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
