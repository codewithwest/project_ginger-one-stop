import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_ginger_one_stop/src/model/download_link_service.dart';
import 'package:project_ginger_one_stop/src/notifiers/image_notifier.dart';
import 'package:project_ginger_one_stop/src/provider/image_handler.dart';
import 'package:project_ginger_one_stop/src/utilities/dropdown.dart';
import 'package:project_ginger_one_stop/src/utilities/elevated_button.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ImageHandler extends StatefulWidget {
  const ImageHandler({super.key});

  @override
  State<ImageHandler> createState() => _ImageHandlerState();
}

class _ImageHandlerState extends State<ImageHandler> {
  final imageData = ImageData();
  File? _image;
  ApiService apiService = ApiService();
  Uint8List? _processedImage;
  bool newImageResponse = false;

  ImageHandlerProvider imageHandlerProvider = ImageHandlerProvider();
  _selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _image = file;
      });
    } else {
      // User canceled the picker
    }
  }

  Future _uploadImage(
    String? imageFormat,
    String? imageHeight,
    String? imageWidth,
  ) async {
    if (_image != null) {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://127.0.0.1:5000/uploadImage'));
      var pic = await http.MultipartFile.fromPath('file', _image!.path);
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
          _processedImage = decodedBytes;
          newImageResponse = true;
        });
      } else {
        throw ('Image upload failed');
      }
    }
  }

  Future<void> downloadImage(Uint8List imageBytes, String imageFormat) async {
    DateTime now = DateTime.now();

    String formattedTime =
        "${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}";

    final downloadsDirectory = await getDownloadsDirectory();
    final videoDownloadsDir =
        "${downloadsDirectory?.path}/ginger_one_stop/images";

    if (!Directory.fromUri(
      Uri(
        path: videoDownloadsDir,
      ),
    ).existsSync()) {
      await Directory(videoDownloadsDir).create(recursive: true);
    }

    try {
      final file = File(
          "$videoDownloadsDir/$formattedTime.${imageFormat.toLowerCase()}");
      await file.writeAsBytes(imageBytes);
      // await tempFile.copy(result);
      print('Image saved to: ${file.path}');
    } catch (e) {
      print('Error saving file: $e');
    }
    // } else {
    //   print('User canceled file saving');
    // }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => imageData,
      child: Consumer<ImageData>(
          builder: (context, data, child) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextUtil(
                      value: "Upload the file you wish to convert",
                      fontsize: 32,
                    ),
                    SizedBox(height: 10),
                    _image != null
                        ? Flexible(
                            flex: 9,
                            child: _processedImage != null
                                ? Image.memory(_processedImage!)
                                : Image.file(_image!),
                          )
                        : Flexible(
                            child: Center(
                              child: Text("No Image Selected"),
                            ),
                          ),
                    _image != null
                        ? TextUtil(value: "Desired outputs")
                        : SizedBox(),
                    SizedBox(height: 15),
                    _image != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: <Widget>[
                                  TextUtil(value: "Format"),
                                  SizedBox(height: 5),
                                  DropDownMenuUtil(
                                    mappedArray:
                                        imageHandlerProvider.imageFormats,
                                    stateValue: data.imageFormat!,
                                    label: "format",
                                    value: "value",
                                    stateUpdater: data.updateProperty,
                                  ),
                                ],
                              ),
                              SizedBox(width: 5),
                              Column(
                                children: [
                                  TextUtil(value: "Width"),
                                  SizedBox(height: 5),
                                  DropDownMenuUtil(
                                    mappedArray:
                                        imageHandlerProvider.imageHeights,
                                    stateValue: data.imageHeight!,
                                    label: "height",
                                    value: "height",
                                    stateUpdater: data.updateProperty,
                                  ),
                                ],
                              ),
                              SizedBox(width: 5),
                              Column(
                                children: [
                                  TextUtil(value: "Height"),
                                  SizedBox(height: 5),
                                  DropDownMenuUtil(
                                    mappedArray:
                                        imageHandlerProvider.imageWidths,
                                    stateValue: data.imageWidth!,
                                    label: "width",
                                    value: "width",
                                    stateUpdater: data.updateProperty,
                                  ),
                                ],
                              ),
                              SizedBox(width: 5),
                            ],
                          )
                        : SizedBox(height: 15),
                    SizedBox(height: 15),
                    newImageResponse
                        ? ElevatedButtonUtil(
                            buttonName: "Download",
                            icon: Icons.download,
                            onClick: () => downloadImage(
                                _processedImage!, data.imageFormat!),
                          )
                        : ElevatedButtonUtil(
                            buttonName:
                                _image == null ? 'Pick Image' : "Upload",
                            icon: Icons.upload,
                            onClick: _image == null
                                ? _selectImage
                                : () => _uploadImage(data.imageFormat,
                                    data.imageHeight, data.imageWidth),
                          ),
                  ],
                ),
              )),
    );
  }
}
