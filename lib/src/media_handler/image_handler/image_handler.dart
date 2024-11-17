import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:project_ginger_one_stop/src/model/download_link_service.dart';
import 'package:project_ginger_one_stop/src/utilities/elevated_button.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageHandler extends StatefulWidget {
  const ImageHandler({super.key});

  @override
  State<ImageHandler> createState() => _ImageHandlerState();
}

class _ImageHandlerState extends State<ImageHandler> {
  File? _image;
  ApiService apiService = ApiService();
  Uint8List? _processedImage;
  String? _imageFormat;
  String? _imageHeight;
  String? _imageWidth;

  final List<Map<String, String>> imageFormats = [
    {"format": "JPG", "value": "JPEG"},
    {"format": "PNG", "value": "PNG"},
  ];

  final List<Map<String, String>> imageHeights = [
    {"height": "16"},
    {"height": "32"},
    {"height": "64"},
    {"height": "128"},
    {"height": "256"},
    {"height": "512"},
    {"height": "720"},
    {"height": "1024"},
    {"height": "2048"},
  ];

  final List<Map<String, String>> imageWidths = [
    {"width": "16"},
    {"width": "32"},
    {"width": "64"},
    {"width": "128"},
    {"width": "256"},
    {"width": "512"},
    {"width": "720"},
    {"width": "1024"},
    {"width": "2048"},
  ];

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

  Future _uploadImage() async {
    if (_image != null) {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://127.0.0.1:5000/uploadImage'));
      var pic = await http.MultipartFile.fromPath('file', _image!.path);
      request.files.add(pic);
      print({
        "height": _imageHeight ?? "None",
        "width": _imageWidth ?? "None",
        "format": _imageFormat ?? "None"
      });
      request.fields.addAll({
        "height": _imageHeight ?? "None",
        "width": _imageWidth ?? "None",
        "format": _imageFormat ?? "None"
      });
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseString = await response.stream.bytesToString();
        var responseData = jsonDecode(responseString);

        var encodedImage = responseData['image_data'];
        var decodedBytes = base64Decode(encodedImage);

        setState(() {
          _processedImage = decodedBytes;
        });
      } else {
        print('Image upload failed');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if ([].isEmpty) {
      _imageFormat = _imageFormat;
    } else {
      _imageFormat = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
          _image != null ? TextUtil(value: "Desired outputs") : SizedBox(),
          SizedBox(height: 15),
          _image != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        TextUtil(value: "Format"),
                        SizedBox(height: 5),
                        dropdownMenu(
                            imageFormats, _imageFormat, "format", "value"),
                      ],
                    ),
                    SizedBox(width: 5),
                    Column(
                      children: [
                        TextUtil(value: "Width"),
                        SizedBox(height: 5),
                        dropdownMenu(
                            imageHeights, _imageHeight, "height", "height"),
                      ],
                    ),
                    SizedBox(width: 5),
                    Column(
                      children: [
                        TextUtil(value: "Height"),
                        SizedBox(height: 5),
                        dropdownMenu(
                            imageWidths, _imageWidth, "width", "width"),
                      ],
                    ),
                    SizedBox(width: 5),
                  ],
                )
              : SizedBox(height: 15),
          SizedBox(height: 15),
          ElevatedButtonUtil(
            buttonName: _image == null ? 'Pick Image' : "Upload",
            icon: Icons.upload,
            onClick: _image == null ? _selectImage : _uploadImage,
          ),
        ],
      ),
    );
  }

  dropdownMenu(
    List<Map<String, String>> mappedArray,
    stateValue,
    String value,
    String label,
  ) {
    return DropdownMenu(
      initialSelection: "",
      onSelected: (String? value) {
        setState(
          () {
            stateValue = value;
            print(stateValue);
          },
        );
      },
      dropdownMenuEntries: mappedArray.map<DropdownMenuEntry<String>>((item) {
        return DropdownMenuEntry(
          value: item[value] ?? "",
          label: item[label] ?? "",
        );
      }).toList(),
    );
  }
}
