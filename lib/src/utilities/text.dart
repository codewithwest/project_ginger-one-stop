import 'package:flutter/material.dart';
import 'package:project_ginger_one_stop/src/provider/colors.dart';

class TextUtil extends StatelessWidget {
  const TextUtil(
      {super.key,
      required this.value,
      this.fontsize = 18,
      this.color = DefaultColors.textDarkColor});

  final double? fontsize;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontSize: fontsize,
        fontFamily: "san-sarif",
        color: color,
      ),
    );
  }
}
