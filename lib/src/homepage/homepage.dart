import 'package:flutter/material.dart';
import 'package:project_ginger_one_stop/src/utilities/elevated_button.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';
import 'package:project_ginger_one_stop/src/media_handler/media_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const routeName = '/';

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: const TextUtil(
                value: "Ginger One Stop",
                fontsize: 30,
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 15,
              children: [
                ElevatedButtonUtil(
                  buttonName: "Media Handler",
                  width: 210,
                  icon: Icons.video_camera_back,
                  onClick: () => Navigator.restorablePushNamed(
                    context,
                    MediaHandler.routeName,
                  ),
                ),
                ElevatedButtonUtil(
                  buttonName: "Data Handler",
                  width: 210,
                  icon: Icons.data_array,
                  onClick: () => Navigator.restorablePushNamed(
                    context,
                    MediaHandler.routeName,
                  ),
                ),
                ElevatedButtonUtil(
                  buttonName: "Text Handler",
                  width: 210,
                  icon: Icons.text_decrease,
                  onClick: () => Navigator.restorablePushNamed(
                    context,
                    MediaHandler.routeName,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
