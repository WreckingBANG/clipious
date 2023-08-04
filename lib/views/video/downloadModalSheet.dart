import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:invidious/controllers/downloadModalSheetController.dart';
import 'package:invidious/main.dart';

import '../../controllers/downloadController.dart';
import '../../models/baseVideo.dart';

const List<String> qualities = <String>['144p', '360p', '720p'];

class DownloadModalSheet extends StatelessWidget {
  final bool animateDownload;
  final BaseVideo video;

  // called when the download is triggerd
  final Function()? onDownload;

  // called when we know whether we can start downloading stuff
  final Function(bool isDownloadStarted)? onDownloadStarted;

  const DownloadModalSheet({Key? key, required this.video, this.animateDownload = false, this.onDownloadStarted, this.onDownload}) : super(key: key);

  static showVideoModalSheet(BuildContext context, BaseVideo video, {bool animateDownload = false, Function(bool isDownloadStarted)? onDownloadStarted, Function()? onDownload}) {
    showModalBottomSheet<void>(
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (BuildContext context) {
          return DownloadModalSheet(
            video: video,
            animateDownload: animateDownload,
            onDownload: onDownload,
            onDownloadStarted: onDownloadStarted,
          );
        });
  }

  void downloadVideo(BuildContext context, DownloadModalSheetController _) async {
    if (onDownload != null) {
      onDownload!();
    }
    var locals = AppLocalizations.of(context)!;
    Navigator.of(context).pop();
    var downloadController = DownloadController.to();
    if (animateDownload) {
      downloadController?.animateToController.animateTag('video-animate-to-${video.videoId}', duration: const Duration(milliseconds: 300), curve: Curves.easeInOutQuad);
    } else {
      scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(locals.videoDownloadStarted)));
    }
    bool canDownload = await downloadController?.addDownload(video.videoId, audioOnly: _.audioOnly, quality: _.quality) ?? false;
    if (!canDownload) {
      scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(locals.videoAlreadyDownloaded)));
    }
    if (onDownloadStarted != null) {
      onDownloadStarted!(canDownload);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locals = AppLocalizations.of(context)!;
    return GetBuilder<DownloadModalSheetController>(
        global: false,
        init: DownloadModalSheetController(),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ToggleButtons(
                        isSelected: qualities.map((e) => e == _.quality).toList(),
                        onPressed: _.audioOnly ? null : (index) => _.setQuality(qualities[index]),
                        children: qualities.map((e) => Text(e)).toList(),
                      ),
                    ),
                    InkWell(
                      onTap: () => _.setAudioOnly(!_.audioOnly),
                      child: Row(
                        children: [
                          Text(locals.videoDownloadAudioOnly),
                          Switch(
                            value: _.audioOnly,
                            onChanged: _.setAudioOnly,
                          )
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => downloadVideo(context, _),
                      icon: const Icon(Icons.download),
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }
}