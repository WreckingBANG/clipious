import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:invidious/comments/views/components/comments_container.dart';
import 'package:invidious/utils/views/components/conditional_wrap.dart';
import 'package:invidious/videos/models/video.dart';
import 'package:invidious/videos/views/components/play_button.dart';
import 'package:invidious/videos/views/components/recommended_videos.dart';

import '../../../globals.dart';
import '../../../player/states/player.dart';
import '../../../settings/states/settings.dart';
import '../../../utils.dart';
import '../../states/video.dart';
import 'add_to_queue_button.dart';
import 'info.dart';
import 'video_thumbnail.dart';

class VideoTabletInnerView extends StatelessWidget {
  final Video video;
  final int selectedIndex;
  final bool? playNow;
  final VideoState videoController;

  const VideoTabletInnerView(
      {super.key,
      required this.video,
      required this.selectedIndex,
      this.playNow,
      required this.videoController});

  List<Widget> getView(BuildContext context,
      {required Orientation orientation}) {
    AppLocalizations locals = AppLocalizations.of(context)!;
    var textTheme = Theme.of(context).textTheme;
    var cubit = context.read<VideoCubit>();
    var settings = context.read<SettingsCubit>();
    String? currentlyPlayingVideoId = context
        .select((PlayerCubit player) => player.state.currentlyPlaying?.videoId);
    final bool restart = currentlyPlayingVideoId == video.videoId;
    return [
      ConditionalWrap(
        wrapper: (Widget child) => Expanded(
          flex: 2,
          child: child,
        ),
        wrapIf: orientation == Orientation.landscape,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: VideoThumbnailView(
                  videoId: video.videoId,
                  thumbnailUrl: video.deArrowThumbnailUrl ??
                      video.getBestThumbnail()?.url ??
                      '',
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PlayButton(
                        icon: restart ? Icons.refresh : null,
                        onPressed:
                            restart ? cubit.restartVideo : cubit.playVideo,
                      ),
                      Positioned(
                          right: 5,
                          bottom: 3,
                          child: AddToQueueButton(
                            videos: [video],
                          ))
                    ],
                  ),
                ),
              ),
              if (!settings.state.distractionFreeMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                        height: 25,
                        child: Checkbox(
                            value: settings.state.playRecommendedNext,
                            onChanged: cubit.togglePlayRecommendedNext,
                            visualDensity: VisualDensity.compact)),
                    InkWell(
                        onTap: () => cubit.togglePlayRecommendedNext(
                            !settings.state.playRecommendedNext),
                        child: Text(
                          locals.addRecommendedToQueue,
                          style: textTheme.bodySmall,
                        ))
                  ],
                ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  // constraints: const BoxConstraints(maxWidth: 500),
                  child: ListView(
                    controller: cubit.scrollController,
                    children: [
                      VideoInfo(
                        video: video,
                        dislikes: videoController.dislikes,
                        descriptionAndTags: false,
                      )
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
      if (!settings.state.distractionFreeMode)
        Expanded(
          flex: 1,
          child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.info),
                        text: locals.info,
                      ),
                      Tab(
                        icon: const Icon(Icons.chat_bubble),
                        text: locals.comments,
                      ),
                      Tab(
                        icon: const Icon(Icons.schema),
                        text: locals.recommended,
                      )
                    ],
                  ),
                  Expanded(
                      child: TabBarView(children: [
                    SingleChildScrollView(
                      child: VideoInfo(
                        video: video,
                        dislikes: videoController.dislikes,
                        titleAndChannelInfo: false,
                      ),
                    ),
                    SingleChildScrollView(
                        child: CommentsContainer(video: video)),
                    SingleChildScrollView(
                        child: RecommendedVideos(video: video))
                  ]))
                ],
              )),
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      var deviceOrientation = getOrientation();
      return deviceOrientation == Orientation.landscape
          ? Row(
              children: getView(context, orientation: deviceOrientation),
            )
          : Column(
              children: getView(context, orientation: deviceOrientation),
            );
    });
  }
}
