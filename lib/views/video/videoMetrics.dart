import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/video.dart';
import '../../utils.dart';

class VideoMetrics extends StatelessWidget {
  final Video? video;
  final int? dislikes;
  final TextStyle? style;
  final double iconSize;
  final int? lengthSeconds, viewCount, likeCount;
  final String? publishedText;

  const VideoMetrics({super.key, this.video, this.dislikes, this.style, this.iconSize = 20, this.lengthSeconds, this.viewCount, this.likeCount, this.publishedText})
      : assert(
            (video != null && lengthSeconds == null && viewCount == null && likeCount == null && publishedText == null) ||
                (video == null && (lengthSeconds != null || viewCount != null || likeCount != null || publishedText != null)),
            'need either a video or given metrics');

  Widget get separator => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        '•',
        style: style,
      ));

  @override
  Widget build(BuildContext context) {
    AppLocalizations locals = AppLocalizations.of(context)!;

    List<Widget> metrics = [];

    var length = video?.lengthSeconds ?? lengthSeconds;
    if (length != null) {
      metrics.addAll([
        Icon(Icons.timer, size: iconSize),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            prettyDuration(Duration(seconds: length)),
            style: style,
          ),
        ),
        separator
      ]);
    }

    var views = video?.viewCount ?? viewCount;
    if (views != null) {
      metrics.addAll([
        Icon(Icons.visibility, size: iconSize),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            compactCurrency.format(views),
            style: style,
          ),
        ),
        separator
      ]);
    }

    var likes = video?.likeCount ?? likeCount;
    if (likes != null) {
      metrics.addAll([
        Icon(Icons.thumb_up, size: iconSize),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            compactCurrency.format(likes),
            style: style,
          ),
        ),
        separator
      ]);
    }

    if (dislikes != null) {
      metrics.addAll([
        Icon(Icons.thumb_down, size: iconSize),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            compactCurrency.format(dislikes).replaceAll(".00", ""),
            style: style,
          ),
        ),
        separator
      ]);
    }

    var date = video?.publishedText ?? publishedText;
    if (date != null || video?.liveNow == true) {
      metrics.addAll([
        (video?.liveNow ?? false)
            ? Visibility(
                visible: video!.liveNow,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.podcasts,
                          size: iconSize,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            locals.streamIsLive,
                            style: style,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Text(
                date ?? '',
                style: style,
              ),
        separator
      ]);
    }

    // removing last separator
    metrics.removeAt(metrics.length - 1);

    return Row(children: metrics);
  }
}
