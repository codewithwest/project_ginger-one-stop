import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_ginger_one_stop/src/media_handler/image_handler/dowloadHelper.dart';
import 'package:project_ginger_one_stop/src/model/download_link_service.dart';
import 'package:project_ginger_one_stop/src/notifiers/image_notifier.dart';
import 'package:project_ginger_one_stop/src/provider/general.dart';
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
  Uint8List? webImage;
  ApiService apiService = ApiService();
  Uint8List? _processedImage;
  bool newImageResponse = false;
  bool isDownloading = false;
  bool downloadComplete = false;
  bool isConverting = false;
  String uploadMessage = "";
  ImageHandlerProvider imageHandlerProvider = ImageHandlerProvider();

  void _selectImage(String? imageFormat) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        // type: FileType.custom,
        // allowedExtensions: ['jpg', 'png', 'jpeg'],
        );
    if (result != null) {
      if (kIsWeb) {
        setState(() {
          webImage = result.files.first.bytes!;
          imageData.imageFormat = result.files.first.extension!;
        });
      } else {
        setState(() {
          _image = File(result.files.single.path!);
        });
      }
    } else {
      // User canceled the picker
    }
  }

  Future _uploadImage(
    String? imageFormat,
    String? imageHeight,
    String? imageWidth,
  ) async {
    try {
      if (_image != null || webImage != null) {
        setState(() {
          uploadMessage = "";
          isConverting = true;
        });
        var request = http.MultipartRequest(
            'POST',
            Uri.parse(kDebugMode
                ? 'http://127.0.0.1:5000/uploadImage'
                //? "https://projectgingeronestopserver-git-dev-codewithwests-projects.vercel.app/graphql"
                : 'https://projectgingeronestopserver.vercel.app/uploadImage'));
        var pic = _image != null
            ? await http.MultipartFile.fromPath('file', _image!.path)
            : http.MultipartFile.fromBytes(
                "file",
                webImage!,
                filename: 'image',
              );
        request.files.add(pic);
        request.fields.addAll({
          "height": imageHeight!,
          "width": imageWidth!,
          "format": imageFormat!
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

  Future<void> downloadImage(
    Uint8List imageBytes,
    String imageFormat,
  ) async {
    try {
      setState(() {
        isDownloading = true;
        uploadMessage = "";
      });

      if (kIsWeb) {
        downloadImageWeb(
            imageBytes, GeneralProvider().timeImageName, imageFormat);
      } else {
        if (!Directory.fromUri(
          Uri(
            path: GeneralProvider().videoDownloadsDir,
          ),
        ).existsSync()) {
          await Directory(
            GeneralProvider().videoDownloadsDir,
          ).create(recursive: true);
        }

        final file = File(
            "${GeneralProvider().videoDownloadsDir}/${GeneralProvider().timeImageName}.${imageFormat.toLowerCase()}");
        await file.writeAsBytes(imageBytes);
      }

      setState(() {
        isDownloading = false;
        downloadComplete = true;
      });
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      uploadMessage = 'Oops Something went wrong, please try again!';
    }
  }

  void reset(data) {
    setState(() {
      isDownloading = false;
      _processedImage = null;
      webImage = null;
      _image = null;
      newImageResponse = false;
      downloadComplete = false;
      data.updateProperty("height", "");
      data.updateProperty("width", "");
      data.updateProperty("format", "");
    });
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
              _processedImage != null
                  ? SizedBox(
                      height: 2,
                    )
                  : TextUtil(
                      value: "Upload the file you wish to convert",
                      fontsize: 32,
                    ),
              SizedBox(height: 10),
              _image != null || webImage != null
                  ? Flexible(
                      flex: 9,
                      child: _processedImage != null
                          ? Image.memory(_processedImage!)
                          : webImage != null
                              ? Image.memory(webImage!)
                              : Image.file(_image!),
                    )
                  : Flexible(
                      child: Center(
                        child: Text("No Image Selected"),
                      ),
                    ),
              _image != null
                  ? _processedImage != null
                      ? SizedBox(
                          height: 2,
                        )
                      : TextUtil(value: "Desired outputs")
                  : SizedBox(),
              SizedBox(height: 15),
              _image != null || webImage != null
                  ? _processedImage != null
                      ? SizedBox(
                          height: 2,
                        )
                      : Row(
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
                                  mappedArray: imageHandlerProvider.imageWidths,
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
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButtonUtil(
                          buttonName:
                              isDownloading ? "Downloading.." : "Download",
                          icon: Icons.download,
                          onClick: isDownloading
                              ? () {}
                              : () => downloadImage(
                                  _processedImage!, data.imageFormat!),
                        ),
                        ElevatedButtonUtil(
                          buttonName: "Reset",
                          icon: Icons.restore,
                          onClick: () => reset(data),
                        ),
                      ],
                    )
                  : ElevatedButtonUtil(
                      buttonName: _image == null && webImage == null
                          ? 'Pick Image'
                          : isConverting
                              ? "Converting..."
                              : "Convert",
                      icon: Icons.upload,
                      onClick: _image == null && webImage == null
                          ? () => _selectImage(data.imageFormat)
                          : () => _uploadImage(data.imageFormat,
                              data.imageHeight, data.imageWidth),
                    ),
              downloadComplete
                  ? TextUtil(
                      value: "Download Complete!",
                      color: Colors.greenAccent,
                      fontsize: 22,
                    )
                  : TextUtil(
                      value: uploadMessage,
                      color: Colors.red,
                      fontsize: 22,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
