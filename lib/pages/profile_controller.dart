import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileController {
  final String cloudName = "your-cloud-name";
  final String uploadPreset = "your-upload-preset";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Pick Image from Gallery or Camera
  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Upload Image to Cloudinary
  Future<String?> uploadImageToCloudinary(File imageFile) async {
    final Uri url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = json.decode(responseData);

    if (response.statusCode == 200) {
      return jsonResponse['secure_url']; // Cloudinary image URL
    } else {
      return null;
    }
  }

  // Save Image URL to Firestore
  Future<void> saveProfileImageUrl(String userId, String imageUrl) async {
    await firestore.collection('users').doc(userId).update({'profileImageUrl': imageUrl});
  }

  // Fetch Profile Image from Firestore
  Future<String?> getProfileImageUrl(String userId) async {
    final docSnapshot = await firestore.collection('users').doc(userId).get();
    if (docSnapshot.exists) {
      return docSnapshot.data()?['profileImageUrl'];
    }
    return null;
  }
}
