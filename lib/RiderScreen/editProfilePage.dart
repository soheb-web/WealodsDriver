/*
import 'package:flutter/material.dart';

class Editprofilepage extends StatefulWidget {
  const Editprofilepage({super.key});

  @override
  State<Editprofilepage> createState() => _EditprofilepageState();
}

class _EditprofilepageState extends State<Editprofilepage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    body: Column(children: [



      ],),);
  }
}
*/

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/model/driverProfileModel.dart';

// ------------------------------------------------------------------
// 1. Paste your DriverProfileModel (the whole file you posted)
// ------------------------------------------------------------------
// (just copy-paste the model code here – it’s the same you already have)
// ------------------------------------------------------------------

class Editprofilepage extends StatefulWidget {
  const Editprofilepage({super.key});

  @override
  State<Editprofilepage> createState() => _EditprofilepageState();
}

class _EditprofilepageState extends State<Editprofilepage> {
  // ------------------------------------------------------------------
  // Controllers & state
  // ------------------------------------------------------------------
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;

  File? _pickedImage; // new image selected by user
  String? _originalImageUrl; // image that came from API
  bool _isLoading = true; // show spinner while fetching
  String? _errorMessage;

  // ------------------------------------------------------------------
  // Replace with your real endpoint & auth header
  // ------------------------------------------------------------------
  static const String _profileUrl = 'https://your-api.com/driver/profile';
  static const String _updateUrl = 'https://your-api.com/driver/profile';
  static const Map<String, String> _headers = {
    'Authorization': 'Bearer YOUR_TOKEN_HERE',
    'Content-Type': 'application/json',
  };

  // ------------------------------------------------------------------
  // Init / dispose
  // ------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _fetchProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // 2. FETCH PROFILE (first time)
  // ------------------------------------------------------------------
  Future<void> _fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse(_profileUrl),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final model = driverProfileModelFromJson(response.body);
        if (model.error == false && model.data != null) {
          final data = model.data!;
          setState(() {
            _firstNameCtrl.text = data.firstName ?? '';
            _lastNameCtrl.text = data.lastName ?? '';
            _originalImageUrl = data.image;
            _isLoading = false;
          });
        } else {
          throw Exception(model.message ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ------------------------------------------------------------------
  // 3. PICK IMAGE
  // ------------------------------------------------------------------
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  // ------------------------------------------------------------------
  // 4. UPDATE PROFILE
  // ------------------------------------------------------------------
  Future<void> _updateProfile() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First & last name are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ---- 1. Build JSON payload (only the fields we allow editing) ----
      final Map<String, dynamic> payload = {
        "firstName": firstName,
        "lastName": lastName,
      };

      // ---- 2. If a new image was chosen → upload as multipart ----
      http.Response response;
      if (_pickedImage != null) {
        var request = http.MultipartRequest('PUT', Uri.parse(_updateUrl))
          ..headers.addAll(_headers)
          ..fields.addAll(payload.map((k, v) => MapEntry(k, v.toString())))
          ..files.add(
            await http.MultipartFile.fromPath('image', _pickedImage!.path),
          );

        final streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      } else {
        // ---- No image → simple JSON PUT ----
        response = await http.put(
          Uri.parse(_updateUrl),
          headers: _headers,
          body: json.encode(payload),
        );
      }

      // ---- 3. Handle result ----
      if (response.statusCode == 200) {
        final model = driverProfileModelFromJson(response.body);
        if (model.error == false && model.data != null) {
          // refresh UI with fresh data (optional)
          final data = model.data!;
          setState(() {
            _originalImageUrl = data.image;
            _pickedImage = null;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
        } else {
          throw Exception(model.message ?? 'Update failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _updateProfile,
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Error: $_errorMessage'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ------------------- PROFILE IMAGE -------------------
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : _originalImageUrl != null
                          ? CachedNetworkImageProvider(_originalImageUrl!)
                          : const AssetImage('assets/placeholder.png')
                                as ImageProvider,
                      child: _pickedImage == null && _originalImageUrl == null
                          ? const Icon(Icons.add_a_photo, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to change photo',
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  // ------------------- FIRST NAME -------------------
                  TextField(
                    controller: _firstNameCtrl,
                    decoration: const InputDecoration(
                      helperText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ------------------- LAST NAME -------------------
                  TextField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ------------------- UPDATE BUTTON -------------------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Update Profile'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
