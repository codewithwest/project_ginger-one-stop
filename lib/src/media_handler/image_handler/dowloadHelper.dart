import 'dart:typed_data';
import 'dart:html';
import 'package:flutter/foundation.dart';

downloadImageWeb(Uint8List imageBytes, String imageName, String imageFormat) {
  if (kIsWeb) {
    final blob = Blob([imageBytes]);
    final url = Url.createObjectUrlFromBlob(blob);
    final anchor = AnchorElement(href: url);
    anchor.download = "$imageName.${imageFormat.toLowerCase()}";
    anchor.click();
    Url.revokeObjectUrl(url);
    return true;
  }
  return true;
}
