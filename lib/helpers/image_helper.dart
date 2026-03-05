import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<String> encodeImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  static Future<String?> pickAndEncodeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null) return null;

    final File imageFile = File(image.path);
    return encodeImageToBase64(imageFile);
  }

  static Image decodeBase64ToImage(String base64String) {
    final bytes = base64Decode(base64String);
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error, size: 50);
      },
    );
  }

  // One function you can call anywhere:
  static Widget buildCardImage(String? imageValue) {
    if (imageValue == null || imageValue.trim().isEmpty) {
      return const Icon(Icons.image, size: 50);
    }

    // Asset path
    if (imageValue.startsWith('assets/')) {
      return Image.asset(
        imageValue,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    }

    // Network URL
    if (imageValue.startsWith('http://') || imageValue.startsWith('https://')) {
      return Image.network(
        imageValue,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    }

    // Otherwise: treat as Base64
    try {
      return decodeBase64ToImage(imageValue);
    } catch (e) {
      return const Icon(Icons.broken_image, size: 50);
    }
  }
}