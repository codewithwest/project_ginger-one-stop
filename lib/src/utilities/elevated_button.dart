import 'package:flutter/material.dart';
import 'package:project_ginger_one_stop/src/provider/colors.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';

// class ElevatedButtonUtil extends StatefulWidget {
//   const ElevatedButtonUtil({
//     super.key,
//     required this.buttonName,
//     this.height = 0,
//     this.width = 0,
//   });

//   final double? height;
//   final double? width;
//   final String buttonName;

//   @override
//   State<ElevatedButtonUtil> createState() => _ElevatedButtonUtilState();
// }

// class _ElevatedButtonUtilState extends State<ElevatedButtonUtil> {
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       style: const ButtonStyle(),
//       onPressed: () {},
//       icon: const Icon(Icons.sunny),
//       label: SizedBox(
//         width: widget.width ?? 0,
//         height: widget.height,
//         child: Center(
//           child: Text(widget.buttonName ?? ""),
//         ),
//       ),
//     );
//   }
// }

class ElevatedButtonUtil extends StatelessWidget {
  const ElevatedButtonUtil({
    super.key,
    required this.buttonName,
    this.icon,
    this.width = 120,
    this.fontsize = 18,
    this.iconColor = DefaultColors.iconDarkColor,
    required this.onClick,
  });

  final double? width;
  final double? fontsize;
  final String buttonName;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: onClick,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              const Color.fromRGBO(17, 4, 4, 0.301),
            ),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.fromLTRB(0, 20, 0, 20)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                side: BorderSide(
                  width: 1.7,
                  color:
                      Colors.transparent, // Color.fromRGBO(1, 62, 133, 0.918),
                ),
              ),
            ),
          ),
          // icon: const Icon(Icons.sunny),
          child: Container(
            width: width,
            margin: const EdgeInsets.all(10),
            child: Column(children: [
              Icon(
                icon,
                color: iconColor,
              ),
              const SizedBox(
                height: 5,
              ),
              Center(
                child: TextUtil(
                  value: buttonName,
                  fontsize: fontsize,
                ),
              ),
            ]),
          ),
        ));
  }
}
