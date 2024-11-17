import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_ginger_one_stop/src/provider/colors.dart';
import 'package:project_ginger_one_stop/src/model/download_link_service.dart';
import 'package:project_ginger_one_stop/src/utilities/elevated_button.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';
import 'package:project_ginger_one_stop/src/media_handler/video_handler/video_data.dart';
import 'package:project_ginger_one_stop/src/media_handler/video_handler/video_resolutions_dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DownloadLinkNotifier extends ChangeNotifier {
  String? _downloadLink = '';

  String? get state => _downloadLink;

  void updateState(String newState) {
    _downloadLink = newState;
    notifyListeners();
  }
}

class YouTubeVideoDownloader extends StatefulWidget {
  const YouTubeVideoDownloader({super.key});

  @override
  State<YouTubeVideoDownloader> createState() => _YouTubeVideoDownloaderState();
}

class _YouTubeVideoDownloaderState extends State<YouTubeVideoDownloader> {
  final _downloadLinkNotifier = DownloadLinkNotifier();

  final TextEditingController controller = TextEditingController();
  List<Object?> formats = [];
  bool displayTextArea = true;
  String videoDownloadsDirectory = "";
  bool downloadComplete = false;
  ApiService apiService = ApiService();
  String errorMessage = "";
  late Map result = {};
  String downloadedFileName = "";

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    Future getDownloadLink() async {
      if (controller.text.contains("https://") &&
          controller.text.contains("www.youtube.com")) {
        try {
          result = await apiService.getYouTubeDownloadLink(controller.text);

          setState(
            () {
              if (result['formats'].runtimeType == List<Object?>) {
                formats = result['formats'];
                displayTextArea = false;
                downloadedFileName = result["title"];
              } else {
                throw ("Oops! An empty Response was received");
              }
            },
          );
        } catch (exception) {
          setState(() {
            errorMessage =
                "Oops! Looks like something went wrong, Please try again!";
            throw ("Oops! An empty Response was received");
          });
        }
      } else {
        setState(() {
          errorMessage = "Incorrect Url";
        });
      }
    }

    Future<void> downloadVideo(String? videoUrl) async {
      final response = await http.get(Uri.parse(videoUrl!));

      final downloadsDirectory = await getDownloadsDirectory();
      final videoDownloadsDir =
          "${downloadsDirectory?.path}/ginger_one_stop/videos";
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        if (!Directory.fromUri(
          Uri(
            path: videoDownloadsDir,
          ),
        ).existsSync()) {
          await Directory(videoDownloadsDir).create(recursive: true);
        }

        final file = File('$videoDownloadsDir/$downloadedFileName.mp4');
        file.writeAsBytesSync(bytes);
        setState(() {
          downloadComplete = true;
          videoDownloadsDirectory = file.path;
        });

        // You can now use the file path to play the video or perform other actions
        throw ('Video downloaded to: ${file.path}');
      } else {
        throw ('Error downloading video: ${response.statusCode}');
      }
    }

    // String youtubeUrl = "";

    // final addStarMutation = useMutation(
    //   MutationOptions(
    //     document: gql(addStar), // this is the mutation string you just created
    //     // you can update the cache based on results
    //     update: (GraphQLDataProxy cache, QueryResult result) {
    //       return cache;
    //     },
    //     // or do something with the result.data on completion
    //     onCompleted: (dynamic resultData) {
    //       print(resultData);
    //     },
    //   ),
    // );

    return ChangeNotifierProvider(
      create: (context) => _downloadLinkNotifier,
      child: Center(
        child: SizedBox(
          height: height / 1.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              downloadComplete
                  ? TextUtil(
                      value:
                          "File Downloaded Succesfully You can the find the file here! \n \n$videoDownloadsDirectory",
                      color: const Color.fromRGBO(45, 216, 2, 0.976),
                    )
                  : TextUtil(
                      fontsize: 25,
                      value: displayTextArea == true
                          ? "Enter Youtube url"
                          : "Click Link below to download your video",
                      color: displayTextArea == false
                          ? DefaultColors.successColor
                          : DefaultColors.textDarkColor,
                    ),
              displayTextArea == true
                  ? SizedBox(
                      width: width > 1080 ? width / 2.2 : width / 1.5,
                      child: TextField(
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: DefaultColors.placeHolderTextColor,
                            ),
                            labelText: "Enter Youtube url",
                            hintStyle: TextStyle(
                              color: DefaultColors.placeHolderTextColor,
                            ),
                            hintText:
                                "https://www.youtube.com/watch?v=LjZxeSne67E"),
                        controller: controller,
                      ),
                    )
                  : downloadComplete
                      ? const SizedBox(
                          height: 0,
                        )
                      : Column(
                          children: [
                            VideoData(
                              data: result,
                            ),
                            VideoResolutionsDropDown(
                              dataList: formats,
                            ),
                          ],
                        ),
              TextUtil(
                value: errorMessage,
                color: const Color.fromARGB(237, 206, 9, 26),
              ),
              Container(
                margin: const EdgeInsets.all(30),
                height: 110,
                child: downloadComplete
                    ? SizedBox.fromSize()
                    : ElevatedButtonUtil(
                        iconColor: displayTextArea == false
                            ? DefaultColors.successColor
                            : DefaultColors.textDarkColor,
                        icon: Icons.download,
                        buttonName: displayTextArea == true
                            ? "Get Download Link"
                            : "Download Video",
                        onClick: () async => displayTextArea == true
                            ? await getDownloadLink()
                            : _downloadLinkNotifier._downloadLink!.isEmpty
                                ? throw ("Download Link: ${_downloadLinkNotifier._downloadLink}")
                                : await downloadVideo(
                                    _downloadLinkNotifier._downloadLink,
                                  ),
                        width: 250,
                        fontsize: 20,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
