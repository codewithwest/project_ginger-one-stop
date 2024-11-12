import 'package:flutter/material.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';

class VideoData extends StatelessWidget {
  const VideoData({super.key, this.data});

  // ignore: prefer_typing_uninitialized_variables
  final data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 12,
        ),
        TextUtil(
          value: "Title: ${data?['title']}",
          fontsize: 16,
        ),
        const SizedBox(height: 2),
        TextUtil(
          value: "Extension: ${data?['ext']}",
          fontsize: 16,
        ),
        const SizedBox(height: 2),
        TextUtil(
          value:
              "Size: ${(int.parse(data['formats']?[data['formats'].length - 1]?['filesize_approx'] ?? '0') / 1000000).toStringAsFixed(2)} mb",
          fontsize: 16,
        ),
        const SizedBox(height: 2),
        TextUtil(
          value: "Highest resolution: ${data?['highest_resolution']}",
          fontsize: 16,
        ),
        const SizedBox(height: 2),
        TextUtil(
          value:
              "video_duration: ${(int.parse(data?['video_duration']) / 60).toStringAsFixed(2)}min",
          fontsize: 16,
        ),
        const SizedBox(height: 2),
        TextUtil(
          value: "Webpage url: ${data?['webpage_url']}",
          fontsize: 16,
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
