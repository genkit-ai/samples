import 'dart:convert';

import 'package:eli5_flutter/camera_screen.dart';
import 'package:eli5_flutter/genkit_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelfiePage extends StatefulWidget {
  final VoidCallback onSelfieTaken;

  const SelfiePage({super.key, required this.onSelfieTaken});

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  final ImagePicker _picker = ImagePicker();
  final GenkitService _genkitService = GenkitService();
  bool _isCartoonifying = false;

  Future<void> _getImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      _cartoonifyAndSave(photo);
    }
  }

  Future<void> _cartoonifyAndSave(XFile photo) async {
    setState(() {
      _isCartoonifying = true;
    });
    try {
      final bytes = await photo.readAsBytes();
      final base64Image = base64Encode(bytes);

      final cartoonUrl = await _genkitService.cartoonify(base64Image);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selfie', base64Image);
      await prefs.setString('cartoon-selfie', cartoonUrl);
      widget.onSelfieTaken();
    } catch (e) {
      // Handle error
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          _isCartoonifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isCartoonifying
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.purple.shade300, Colors.blue.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'ELI',
                          style: TextStyle(
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '5',
                          style: TextStyle(
                            fontSize: 130,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 8.0,
                                color: Colors.purple.withOpacity(0.3),
                                offset: const Offset(4.0, 4.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Submit a question and get a simple explanation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'First, a Selfie!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _getImage(ImageSource.gallery),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload a File'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.purple.shade300,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CameraScreen(
                                onPictureTaken: (image) {
                                  _cartoonifyAndSave(image);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take a Picture'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.orange.shade400,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
