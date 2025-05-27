import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/core/models/song_file.dart';
import 'package:music_player/core/services/playback_service.dart';

class PlayerController extends GetxController {
  final PlaybackService _playbackService = PlaybackService();
  RxBool isPlaying = false.obs;
  RxBool isLooping = false.obs; // New loop mode state
  RxBool isShuffled = false.obs; // New flag for shuffle mode
  Rx<Duration> position = Duration.zero.obs;
  Rx<Duration> duration = Duration.zero.obs;
  RxInt currentIndex = 0.obs;
  RxList<SongFile> songs = <SongFile>[].obs;
  RxString title = 'Song'.obs;
  RxList<String> playlist = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _setupStreams();
  }

  void _setupStreams() {
    _playbackService.player.playingStream.listen((playing) {
      isPlaying.value = playing;
    });
    _playbackService.player.positionStream.listen((pos) {
      position.value = pos;
    });
    _playbackService.player.durationStream.listen((dur) {
      duration.value = dur ?? Duration.zero;
    });
    _playbackService.player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      final currentItem = sequenceState.currentIndex;
      if (currentItem != currentIndex.value) {
        currentIndex.value = currentItem;
        // log('PlayerController: Updated currentIndex to $currentItem');
      }

      if (sequenceState.sequence.isEmpty ||
          currentItem >= sequenceState.sequence.length - 1) {
        _playbackService.player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            isPlaying.value = true;
            currentIndex.value = 0; // Reset to first song
            // log('Playback completed, resetting to first song');
            seek(Duration.zero);
            play();
          }
        });
      }
    });
  }

  Future<void> init(List<SongFile> songList, int initialIndex) async {
    try {
      songList.map((value) {
        if (value.playlists.isNotEmpty) {
          playlist.value = value.playlists;
        }
      });
      songs.value = songList;
      currentIndex.value = initialIndex;
      await _playbackService.init(songList, initialIndex);

      play();
    } catch (e) {
      Get.snackbar('Error', 'Failed to play song: $e');
    }
  }

  void play() => _playbackService.play();
  void pause() => _playbackService.pause();
  void seek(Duration position) => _playbackService.seek(position);
  Future<void> next() async {
    if (currentIndex.value < songs.length - 1) {
      currentIndex.value++;
      await _playbackService.next();
      isPlaying.value = true;
      // play(); // Ensure the next song starts playing
    }
  }

  Future<void> previous() async {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      await _playbackService.previous();
      isPlaying.value = true;
      // play(); // Ensure the previous song starts playing
    }
  }

  void toggleLoop() {
    isLooping.value = !isLooping.value;
    _playbackService.player.setLoopMode(
      isLooping.value ? LoopMode.one : LoopMode.off,
    );
  }

  @override
  void onClose() {
    _playbackService.dispose();
    super.onClose();
  }
}
