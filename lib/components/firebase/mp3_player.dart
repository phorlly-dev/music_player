import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/components/global/duration_bloc.dart';
import 'package:music_player/components/global/sample.dart';
import 'package:music_player/core/dialogs/index.dart';
import 'package:music_player/core/messages/index.dart';
import 'package:music_player/core/models/audio_file.dart';
import 'package:music_player/core/services/music_service.dart';
import 'package:music_player/components/global/audio_form.dart';
import 'package:music_player/components/global/topbar.dart';

class MP3Player extends StatefulWidget {
  final List<AudioFile> playlist;
  final int initialIndex;
  final String title;

  const MP3Player({
    super.key,
    required this.playlist,
    required this.initialIndex,
    required this.title,
  });

  @override
  State<MP3Player> createState() => _MP3PlayerState();
}

class _MP3PlayerState extends State<MP3Player> {
  final AudioPlayer _player = AudioPlayer();
  final service = MusicService();
  late int currentIndex;
  late List<AudioFile> playlist; // Mutable playlist in state
  late List<AudioFile> originalPlaylist; // Keep the original order
  bool isLooping = false;
  bool isShuffled = false; // New flag to track shuffle mode

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    originalPlaylist = List.from(widget.playlist); // Store the original order
    playlist = List.from(widget.playlist); // Mutable copy for sorting/shuffling
    _init();

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (currentIndex < widget.playlist.length - 1) {
          // Automatically go to the next song when the current one finishes
          goToNext();
        } else {
          setState(() {
            // Optionally reset the player when the last song finishes
            currentIndex = 0; // Reset to the first song
            _loadAudio(); // Reload the first song
          });
        }
      }
    });
  }

  Future<void> _init() async {
    await _loadAudio();
  }

  Future<void> _loadAudio() async {
    try {
      await _player.setAudioSource(
        AudioSource.asset(playlist[currentIndex].url),
      );

      _player.seek(Duration.zero); // Reset position to 0
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

  void goToNext() {
    if (currentIndex < widget.playlist.length - 1) {
      final wasPlaying = _player.playing;
      setState(() {
        currentIndex++;
      });
      _loadAudio().then((_) {
        if (wasPlaying) {
          _player.play();
        }
      });
    }
  }

  void goToPrevious() {
    if (currentIndex > 0) {
      final wasPlaying = _player.playing;
      setState(() {
        currentIndex--;
      });
      _loadAudio().then((_) {
        if (wasPlaying) {
          _player.play();
        }
      });
    }
  }

  // New method to toggle between sorted and random playback
  void togglePlaybackMode() {
    setState(() {
      isShuffled = !isShuffled;
      if (isShuffled) {
        // Shuffle the playlist
        playlist.shuffle();
        // Find the current song's new index after shuffling
        final currentSong = originalPlaylist[currentIndex];
        currentIndex = playlist.indexOf(currentSong);
      } else {
        // Restore the sorted order (e.g., by title)
        playlist = List.from(originalPlaylist);
        playlist.sort((a, b) => a.title.compareTo(b.title));
        // Find the current song's new index after sorting
        final currentSong = originalPlaylist[currentIndex];
        currentIndex = playlist.indexOf(currentSong);
      }
    });

    // Reload the current audio to ensure consistency
    // _loadAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAudio = playlist[currentIndex];

    return SafeArea(
      child: Topbar(
        title: "Music from ${widget.title}",
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageAssetAvatr(
                  path: currentAudio.artworkUrl,
                  widthFraction: 0.8,
                ),
                const SizedBox(height: 20),
                Text(
                  currentAudio.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${currentAudio.artist} • ${currentAudio.album}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_document),
                      onPressed: () {
                        AudioForm.showFormTo(context, currentAudio);
                      },
                      tooltip: "Edit Document",
                    ),
                    IconButton(
                      icon: Icon(
                        currentAudio.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: currentAudio.isFavorite ? Colors.red : null,
                      ),
                      onPressed: () async {
                        bool newFavoriteStatus = !currentAudio.isFavorite;
                        final updatedAudio = AudioFile(
                          id: currentAudio.id,
                          title: currentAudio.title,
                          artist: currentAudio.artist,
                          album: currentAudio.album,
                          duration: currentAudio.duration,
                          url: currentAudio.url,
                          artworkUrl: currentAudio.artworkUrl,
                          isFavorite: newFavoriteStatus,
                        );

                        await service.update(updatedAudio).whenComplete(() {
                          if (context.mounted) {
                            newFavoriteStatus
                                ? Msg.message(
                                    message: 'Added to favorite!',
                                    context,
                                  )
                                : Msg.message(
                                    context,
                                    message: 'Removed from favorite!',
                                    bgColor: Colors.blueGrey,
                                  );
                          }
                        });
                        setState(() {
                          // Update the playlist with the new favorite status
                          playlist[currentIndex] = updatedAudio;
                        });
                      },
                      tooltip: "Add to Favorite",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      onPressed: () {
                        Popup.confirmDelete(
                          context,
                          message: currentAudio.title,
                          confirmed: () async {
                            await service.remove(currentAudio.id);
                            Get.back();
                            Msg.showSuccess(
                              title: 'Remove the music',
                              message: 'Removed the ${currentAudio.title}',
                            );
                          },
                        );
                      },
                      tooltip: "Remove Document",
                    ),
                  ],
                ),

                DurationBloc(
                  durationStream: _player.durationStream,
                  positionStream: _player.positionStream,
                  player: _player,
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () {
                        final newPosition =
                            _player.position - const Duration(seconds: 10);
                        _player.seek(
                          newPosition > Duration.zero
                              ? newPosition
                              : Duration.zero,
                        );
                      },
                      iconSize: 24,
                    ),
                    IconButton(
                      icon: Icon(
                        isShuffled ? Icons.shuffle : Icons.sort,
                        color: isShuffled ? Colors.cyan : Colors.blueAccent,
                      ),
                      onPressed: togglePlaybackMode,
                      iconSize: 24,
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        color: currentIndex > 0 ? null : Colors.grey,
                      ),
                      onPressed: currentIndex > 0 ? goToPrevious : null,
                      iconSize: 30,
                    ),
                    StreamBuilder<bool>(
                      stream: _player.playingStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          color: isPlaying ? Colors.red : Colors.green,
                          iconSize: 40,
                          onPressed: () =>
                              isPlaying ? _player.pause() : _player.play(),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color: currentIndex < playlist.length - 1
                            ? null
                            : Colors.grey,
                      ),
                      onPressed: currentIndex < playlist.length - 1
                          ? goToNext
                          : null,
                      iconSize: 30,
                    ),
                    IconButton(
                      icon: Icon(isLooping ? Icons.repeat_one : Icons.repeat),
                      onPressed: () {
                        setState(() {
                          isLooping = !isLooping;
                          _player.setLoopMode(
                            isLooping ? LoopMode.one : LoopMode.off,
                          );
                        });
                      },
                      iconSize: 24,
                      color: isLooping ? Colors.amber : Colors.blueGrey,
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, size: 26),
                      onPressed: () {
                        final newPosition =
                            _player.position + const Duration(seconds: 10);
                        final duration = _player.duration ?? Duration.zero;
                        _player.seek(
                          newPosition < duration ? newPosition : duration,
                        );
                      },
                      iconSize: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
