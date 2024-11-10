import 'package:flutter/material.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';

class VideoData extends StatelessWidget {
  const VideoData({super.key, this.data});

  final data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextUtil(value: "Title: ${data?['title']}"),
        const SizedBox(height: 2),
        TextUtil(value: "Extension: ${data?['ext']}"),
        const SizedBox(height: 2),
        TextUtil(
            value:
                "Size: ${(int.parse(data['formats']?[data['formats'].length - 1]?['filesize_approx'] ?? '0') / 1000000).toStringAsFixed(2)} mb"),
        const SizedBox(height: 2),
        TextUtil(value: "Highest resolution: ${data?['highest_resolution']}"),
        const SizedBox(height: 2),
        TextUtil(
            value:
                "video_duration: ${(int.parse(data?['video_duration']) / 60).toStringAsFixed(2)}min"),
        const SizedBox(height: 2),
        TextUtil(value: "Webpage url: ${data?['webpage_url']}"),
        const SizedBox(height: 15),
      ],
    );
  }
}
