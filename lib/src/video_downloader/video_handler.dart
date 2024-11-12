import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_ginger_one_stop/src/provider/colors.dart';
import 'package:project_ginger_one_stop/src/service/download_link_service.dart';
import 'package:project_ginger_one_stop/src/utilities/elevated_button.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';
import 'package:project_ginger_one_stop/src/video_downloader/video_data.dart';
import 'package:project_ginger_one_stop/src/video_downloader/video_resolutions_dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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
                                ? print(
                                    "Download Link: ${_downloadLinkNotifier._downloadLink}")
                                : await downloadVideo(
                                    // "https://rr2---sn-uxa3vh-j2uz.googlevideo.com/videoplayback?expire=1731195218&ei=8pwvZ86cHL_fvdIP3rGyqQE&ip=165.165.108.166&id=o-ANNxX-Oi_COHTzJRwaDtgQHBhi5YOclk_e_csWoqwOJr&itag=249&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&met=1731173618%2C&mh=AT&mm=31%2C29&mn=sn-uxa3vh-j2uz%2Csn-aigl6nsd&ms=au%2Crdu&mv=m&mvi=2&pl=18&rms=au%2Cau&initcwndbps=408750&bui=AQn3pFRCV6vMVjbmlawqAntLsSk96Rz0oXW-a2MUf3WNAmvRsGHGv7m0BcX7j6Qf5L3fCfvsIvslequF&spc=qtApAbAPtSCpwQe5tml6ZvXSdh_VJPJ5z9-MFjDUpyuy3xXciWeVeJMCo53B&vprv=1&svpuc=1&mime=audio%2Fwebm&ns=4ue8zf6JvWTWRmGrk-iy_XwQ&rqh=1&gir=yes&clen=37998343&dur=6064.801&lmt=1731040171480475&mt=1731173111&fvip=5&keepalive=yes&fexp=51299153%2C51312688%2C51326932&c=WEB&sefc=1&txp=4432434&n=Tov7dt_BC_tUWK8&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cbui%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Cns%2Crqh%2Cgir%2Cclen%2Cdur%2Clmt&sig=AJfQdSswRAIgTDawOtejvB0C96a1PJ8PXKGOh9N7oF19ZKiuudmx8IgCIAnynycIDngRhgzM4EzyejSjTOEr20Ri_Q357JzGHzjr&lsparams=met%2Cmh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Crms%2Cinitcwndbps&lsig=AGluJ3MwRAIgQNCNAcoOrkd6ixw3JNi8_ZRq2XCoj3StVkUlS6AMYZ0CIBKD1VFT-kogXhoUO4GNJQwDM5YmtWQy_ClyT3TpieW3",
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
