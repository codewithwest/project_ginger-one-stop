import 'package:flutter/material.dart';
import 'package:project_ginger_one_stop/src/media_handler/video_handler/video_downloader.dart';
import 'package:project_ginger_one_stop/src/utilities/text.dart';
import 'package:provider/provider.dart';

class VideoResolutionsDropDown extends StatefulWidget {
  const VideoResolutionsDropDown({
    super.key,
    required this.dataList,
    // required this.dropDownValue,
  });
  final List<Object?> dataList;
  // final String dropDownValue;

  @override
  State<VideoResolutionsDropDown> createState() =>
      _VideoResolutionsDropDownState();
}

class _VideoResolutionsDropDownState extends State<VideoResolutionsDropDown> {
  String? _dropdownValue;

  @override
  void initState() {
    super.initState();
    if (widget.dataList.isNotEmpty && widget.dataList.first is Map) {
      _dropdownValue =
          _dropdownValue = (widget.dataList.first as Map)["url"] as String?;
    } else {
      _dropdownValue = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<DownloadLinkNotifier>(context);

    return widget.dataList.isEmpty
        ? const TextUtil(value: "Opps failed to load video resolutions")
        : DropdownMenu(
            initialSelection: _dropdownValue,
            onSelected: (String? value) {
              setState(() {
                _dropdownValue = value;
                notifier.updateState(value!);
              });
            },
            dropdownMenuEntries:
                widget.dataList.map<DropdownMenuEntry<String>>((item) {
              if (item is Map) {
                setState(() {
                  notifier.updateState(item["url"]);
                });
                return DropdownMenuEntry(
                  value: item["url"],
                  label: item["resolution"] as String,
                );
              } else {
                return const DropdownMenuEntry(
                    value: "", label: "Invalid Data");
              }
            }).toList(),
          );
  }
}
