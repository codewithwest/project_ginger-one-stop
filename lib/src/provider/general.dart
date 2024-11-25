import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

DateTime now = DateTime.now();
final downloadsDirectory = getDownloadsDirectory();

class GeneralProvider {
  String timeImageName =
      "${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}";

  final videoDownloadsDir = "${downloadsDirectory.path}/ginger_one_stop/images";

  Future uploadImage(
      setState,
      String? imageFormat,
      String? imageHeight,
      String? imageWidth,
      webImage,
      uploadMessage,
      isConverting,
      image,
      processedImage,
      newImageResponse) async {
    try {
      if (image != null || webImage != null) {
        setState(() {
          uploadMessage = "";
          isConverting = true;
        });
        var request = http.MultipartRequest(
            'POST', Uri.parse('http://127.0.0.1:5000/uploadImage'));
        var pic = image != null
            ? await http.MultipartFile.fromPath('file', image!.path)
            : http.MultipartFile.fromBytes(
                "file",
                webImage!,
                filename: 'image.jpg',
              );

        request.files.add(pic);
        request.fields.addAll({
          "height": imageHeight ?? "None",
          "width": imageWidth ?? "None",
          "format": imageFormat ?? "None"
        });
        var response = await request.send();
        if (response.statusCode == 200) {
          var responseString = await response.stream.bytesToString();
          var responseData = jsonDecode(responseString);

          var encodedImage = responseData['image_data'];
          var decodedBytes = base64Decode(encodedImage);

          setState(() {
            processedImage = decodedBytes;
            newImageResponse = true;
            isConverting = false;
          });
        } else {
          setState(() {
            uploadMessage = ('Image upload failed, Please try again!');
            isConverting = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isConverting = false;
        uploadMessage = ('Image upload failed, Please try again!');
      });
    }
  }
}

extension on Future<Directory?> {
  get path => null;
}
