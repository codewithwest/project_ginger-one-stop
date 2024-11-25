import 'package:flutter/material.dart';
import 'package:project_ginger_one_stop/src/media_handler/image_handler/image_handler.dart';
import 'package:project_ginger_one_stop/src/media_handler/video_handler/video_downloader.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';

class MediaHandler extends StatefulWidget {
  const MediaHandler({super.key});

  @override
  MediaHandlerState createState() => MediaHandlerState();
  static const routeName = '/media-handler';
}

class MediaHandlerState extends State<MediaHandler> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const YouTubeVideoDownloader(),
    const ImageHandler(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const TextUtil(
        value: "Media Handler",
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
            icon: Icon(Icons.video_collection_outlined),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_library_music_rounded),
            label: 'Music',
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Music Handler'),
    );
  }
}
