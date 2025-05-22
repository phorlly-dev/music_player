import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/core/functions/index.dart';

class DurationBloc extends StatelessWidget {
  final AudioPlayer player;
  final Stream<DurationState> durationStream;

  const DurationBloc({
    super.key,
    required this.player,
    required this.durationStream,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width * .5; // Derive from playlist

    String formatDuration(Duration duration) {
      int hours = duration.inHours;
      int minutes = duration.inMinutes.remainder(60);
      int seconds = duration.inSeconds.remainder(60);

      if (hours == 0) {
        return '${Funcs.numToStr(minutes)}:${Funcs.numToStr(seconds)}';
      } else {
        return '${Funcs.numToStr(hours)}:${Funcs.numToStr(minutes)}:${Funcs.numToStr(seconds)}';
      }
    }

    return StreamBuilder<DurationState>(
      stream: durationStream,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final position = durationState?.position ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatDuration(position)),
            SizedBox(
              width: width,
              child: Slider(
                min: 0.0,
                max: total.inMilliseconds.toDouble(),
                value: position.inMilliseconds.toDouble().clamp(
                  0.0,
                  total.inMilliseconds.toDouble(),
                ),
                onChanged: (value) {
                  player.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
            Text(formatDuration(total)),
          ],
        );
      },
    );
  }
}

class DurationState {
  final Duration position, total;

  DurationState(this.position, this.total);
}
