import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class OrgHomePage extends StatefulWidget {
  final String profileImageUrl;
  final String displayName;
  final String email;

  const OrgHomePage({
    Key? key,
    required this.profileImageUrl,
    required this.displayName,
    required this.email,
  }) : super(key: key);

  @override
  _OrgHomePageState createState() => _OrgHomePageState();
}

class _OrgHomePageState extends State<OrgHomePage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDescriptionController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController ticketPriceController = TextEditingController();

  String selectedCategory = 'Music';
  String selectedLocation = 'Colombo';
  File? _eventImage;
  bool _isUploading = false;

  final List<String> categories = [
    'Music',
    'Business',
    'Food',
    'Art',
    'Films',
    'Sports',
  ];

  final List<String> sriLankanLocations = [
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Matale',
    'Nuwara Eliya',
    'Galle',
    'Matara',
    'Hambantota',
    'Jaffna',
    'Kilinochchi',
    'Mannar',
    'Mullaitivu',
    'Vavuniya',
    'Batticaloa',
    'Ampara',
    'Trincomalee',
    'Kurunegala',
    'Puttalam',
    'Anuradhapura',
    'Polonnaruwa',
    'Badulla',
    'Monaragala',
    'Ratnapura',
    'Kegalle',
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _eventImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dwuzpk4cd'; // Replace with your Cloudinary cloud name
    const uploadPreset = 'localevent'; // Replace with your Cloudinary unsigned upload preset

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url);

    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      return jsonResponse['secure_url'];
    } else {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }

  Future<void> _createEvent() async {
    if (_eventImage == null ||
        eventNameController.text.isEmpty ||
        eventDescriptionController.text.isEmpty ||
        eventDateController.text.isEmpty ||
        ticketPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and select an image.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image to Cloudinary
      final imageUrl = await _uploadImageToCloudinary(_eventImage!);

      // Add event details to Firestore
      await FirebaseFirestore.instance.collection('events').add({
        'title': eventNameController.text.trim(),
        'description': eventDescriptionController.text.trim(),
        'dateTime': eventDateController.text.trim(),
        'location': selectedLocation,
        'category': selectedCategory,
        'image': imageUrl,
        'organizer': widget.displayName,
        'ticketPrice': ticketPriceController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );

      eventNameController.clear();
      eventDescriptionController.clear();
      eventDateController.clear();
      ticketPriceController.clear();
      setState(() {
        _eventImage = null;
        selectedCategory = 'Music';
        selectedLocation = 'Colombo';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: eventNameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: eventDescriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Event Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              items: sriLankanLocations.map((location) {
                return DropdownMenuItem(value: location, child: Text(location));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: eventDateController,
              decoration: const InputDecoration(
                labelText: 'Event Date (e.g., 2024-12-31)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ticketPriceController,
              decoration: const InputDecoration(
                labelText: 'Ticket Price (e.g., RS.5000)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            _eventImage != null
                ? Image.file(_eventImage!, height: 200, width: double.infinity, fit: BoxFit.cover)
                : const SizedBox.shrink(),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Choose Event Image'),
            ),
            const SizedBox(height: 15),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createEvent,
                    child: const Text('Create Event'),
                  ),
          ],
        ),
      ),
    );
  }
}
