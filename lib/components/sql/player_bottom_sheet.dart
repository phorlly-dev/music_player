import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/global/sample.dart';
import 'package:music_player/core/controllers/player_controller.dart';

class PlayerBottomSheet extends GetView<PlayerController> {
  final VoidCallback? pushTo;
  const PlayerBottomSheet({this.pushTo, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Obx(() {
            final currentSong = controller.songs[controller.currentIndex.value];
            return ListTile(
              leading: ImgAsset(path: currentSong.artworkUrl),
              title: Text(currentSong.title),
              subtitle: Text('${currentSong.artist} • ${currentSong.album}'),
              trailing: IconButton(
                icon: Icon(
                  controller.isLooping.value ? Icons.repeat_one : Icons.repeat,
                ),
                onPressed: controller.toggleLoop,
                color: controller.isLooping.value ? Colors.red : Colors.green,
              ),
              onTap: pushTo,
            );
          }),
          Obx(() {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(controller.position.value)),

                  Slider(
                    value: controller.position.value.inSeconds.toDouble(),
                    min: 0.0,
                    max: controller.duration.value.inSeconds.toDouble(),
                    onChanged: (value) {
                      controller.seek(Duration(seconds: value.toInt()));
                    },
                  ),

                  Text(_formatDuration(controller.duration.value)),
                ],
              ),
            );
          }),
          Obx(() {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Button
                  IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      color: controller.currentIndex.value > 0
                          ? null
                          : Colors.grey,
                    ),
                    onPressed: controller.currentIndex.value > 0
                        ? controller.previous
                        : null,
                    iconSize: 30,
                  ),
                  IconButton(
                    icon: Icon(
                      controller.isPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () {
                      if (controller.isPlaying.value) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    },
                    color: controller.isPlaying.value
                        ? Colors.red
                        : Colors.green,
                  ),
                  // Next Button
                  IconButton(
                    icon: Icon(
                      Icons.skip_next,
                      color:
                          controller.currentIndex.value <
                              controller.songs.length - 1
                          ? null
                          : Colors.grey,
                    ),
                    onPressed:
                        controller.currentIndex.value <
                            controller.songs.length - 1
                        ? controller.next
                        : null,
                    iconSize: 30,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours == 0) {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
