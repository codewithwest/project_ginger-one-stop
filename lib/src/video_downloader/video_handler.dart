import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_ginger_one_stop/src/service/download_link_service.dart';
import 'package:project_ginger_one_stop/src/utilities/elevated_button.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as universal_html;
import 'package:mime/mime.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

class VideoHandler extends StatefulWidget {
  const VideoHandler({super.key});

  @override
  VideoHandlerState createState() => VideoHandlerState();
  static const routeName = '/video-handler';
}

class VideoHandlerState extends State<VideoHandler> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const YouTubeVideoDownloader(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const TextUtil(
        value: "Video Handler",
        fontsize: 26,
      )),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class YouTubeVideoDownloader extends StatefulWidget {
  const YouTubeVideoDownloader({super.key});

  @override
  State<YouTubeVideoDownloader> createState() => _YouTubeVideoDownloaderState();
}

class _YouTubeVideoDownloaderState extends State<YouTubeVideoDownloader> {
  final TextEditingController controller = TextEditingController();
  String downloadLink = "";
  bool displayTextArea = true;
  ApiService apiService = ApiService();
  String errorMessage = "";
  late Map result;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    getDownloadLink() async {
      if (controller.text.contains("https://") &&
          controller.text.contains("www.youtube.com")) {
        result = await apiService.getYouTubeDownloadLink(controller.text);
        setState(
          () {
            if (result['download_link'].runtimeType == String) {
              downloadLink = result['download_link'];
              displayTextArea = false;
              print("The download link: $downloadLink");
            } else {
              print("An empty Response was received");
            }
          },
        );
      } else {
        setState(() {
          errorMessage = "Incorrect Url";
        });
      }
    }

    // Future<void> downloadFile(String url, String fileName) async {
    //   final dio = Dio();
    //   final directory = await getApplicationDocumentsDirectory();
    //   final path = '${directory.path}/$fileName';
    //   await dio.download(url, path);
    // }
    Future<void> downloadVideo(String videoUrl) async {
      final response = await http.get(Uri.parse(videoUrl));
      final downloadsDirectory = await getDownloadsDirectory();
      final videoDownloadsDirectory =
          "${downloadsDirectory?.path}/ginger_one_stop/videos";
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        if (!Directory.fromUri(
          Uri(
            path: videoDownloadsDirectory,
          ),
        ).existsSync()) {
          await Directory(videoDownloadsDirectory).create(recursive: true);
        }

        final file = File('$videoDownloadsDirectory/test_video_down.mp4');
        file.writeAsBytesSync(bytes);

        // You can now use the file path to play the video or perform other actions
        print('Video downloaded to: ${file.path}');
      } else {
        print('Error downloading video: ${response.statusCode}');
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

    return Center(
      child: SizedBox(
        height: height / 1.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextUtil(
              value: displayTextArea == true
                  ? "Enter Youtube url"
                  : "Click Link below to download your video",
              color: displayTextArea == false
                  ? const Color.fromRGBO(45, 216, 2, 0.976)
                  : null,
            ),
            displayTextArea == true
                ? SizedBox(
                    width: width > 1080 ? width / 2.2 : width / 1.5,
                    child: TextField(
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Enter Youtube url",
                          hintText:
                              "https://www.youtube.com/watch?v=ECkBOQoB0Xc"),
                      controller: controller,
                    ),
                  )
                : SizedBox(),
            TextUtil(
              value: errorMessage,
              color: const Color.fromARGB(237, 206, 9, 26),
            ),
            Container(
              margin: const EdgeInsets.all(30),
              height: 110,
              child: ElevatedButtonUtil(
                icon: Icons.download,
                buttonName: displayTextArea == true
                    ? "Get Download Link"
                    : "Download Video",
                onClick: () async =>
                    // getDownloadLink(),
                    // displayTextArea == false
                    //     ? await getDownloadLink()
                    await downloadVideo(
                  "http://127.0.0.1:5000/",
                ),
                width: 250,
                fontsize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Favorites Screen'),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Screen'),
    );
  }
}

class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);
  @override
  State<MyScreen> createState() => MyScreenState();
}

class MyScreenState extends State<MyScreen> {
  // Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    player.open(Media(
        'https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4'));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 9.0 / 16.0,
        // Use [Video] widget to display video output.
        child: Video(controller: controller),
      ),
    );
  }
}
