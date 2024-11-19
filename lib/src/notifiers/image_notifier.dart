import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageData extends ChangeNotifier {
  File? image;
  Uint8List? processedImage;
  String? imageFormat = "";
  String? imageHeight = "";
  String? imageWidth = "";

  // Update functions for format, height, and width
  void updateProperty(String property, String value) {
    switch (property) {
      case "format":
        imageFormat = value;
        break;
      case "height":
        imageHeight = value;
        break;
      case "width":
        imageWidth = value;
        break;
      default:
        break;
    }
    notifyListeners();
  }
}

class ImageInfo {
  final String? format;
  final String? height;
  final String? width;

  const ImageInfo({
    this.format,
    this.height,
    this.width,
  });

  ImageInfo copyWith({
    String? format,
    String? height,
    String? width,
  }) {
    return ImageInfo(
      format: format ?? this.format,
      height: height ?? this.height,
      width: width ?? this.width,
    );
  }
}
