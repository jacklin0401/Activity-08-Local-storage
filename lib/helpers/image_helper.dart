import 'package:flutter/material.dart';

class ImageHelper {

  static Widget buildCardImage(String? imageUrl) {

    if (imageUrl == null || imageUrl.isEmpty) {
      return const Icon(Icons.image, size: 50);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 50);
      },
    );
  }

}