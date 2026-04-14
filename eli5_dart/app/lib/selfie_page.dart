import 'dart:convert';

import 'package:eli5_flutter/camera_screen.dart';
import 'package:eli5_flutter/eli5_logo.dart';
import 'package:eli5_flutter/genkit_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelfiePage extends StatefulWidget {
  final VoidCallback onSelfieTaken;
  final VoidCallback onSelfieCleared;
  final String? currentCartoonSelfie;

  const SelfiePage({
    super.key,
    required this.onSelfieTaken,
    required this.onSelfieCleared,
    this.currentCartoonSelfie,
  });

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  final ImagePicker _picker = ImagePicker();
  final GenkitService _genkitService = GenkitService();
  bool _isCartoonifying = false;
  String? _errorMessage;

  Future<void> _getImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      _cartoonifyAndSave(photo);
    }
  }

  Future<void> _cartoonifyAndSave(XFile photo) async {
    setState(() {
      _isCartoonifying = true;
      _errorMessage = null;
    });
    try {
      final bytes = await photo.readAsBytes();
      final base64Image = base64Encode(bytes);

      final cartoonUrl = await _genkitService.cartoonify(base64Image);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selfie', base64Image);
      await prefs.setString('cartoon-selfie', cartoonUrl);
      HapticFeedback.mediumImpact();
      widget.onSelfieTaken();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to create cartoon. Try again!');
      }
    } finally {
      if (mounted) {
        setState(() => _isCartoonifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasSelfie = widget.currentCartoonSelfie != null;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasSelfie) ...[
                Text(
                  'Your Avatar',
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Semantics(
                  label: 'Your cartoon avatar',
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage:
                        NetworkImage(widget.currentCartoonSelfie!),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Your selfie is used to personalize story illustrations.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ] else ...[
                const Eli5Logo(fontSize: 80),
                const SizedBox(height: 16),
                Text(
                  'Add a selfie to personalize\nyour story illustrations!',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
              ],
              if (_isCartoonifying) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Creating your cartoon avatar...',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else ...[
                if (_errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _errorMessage!,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: 'Upload a photo from gallery',
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _getImage(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.upload_file),
                        label: Text(hasSelfie ? 'New Photo' : 'Upload a File'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: colorScheme.onPrimary,
                          backgroundColor: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      label: 'Take a new photo with camera',
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
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
                          foregroundColor: colorScheme.onTertiary,
                          backgroundColor: colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasSelfie) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onSelfieCleared();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove Avatar'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
