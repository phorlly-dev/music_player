import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/components/global/duration_bloc.dart';
import 'package:music_player/components/global/sample.dart';
import 'package:music_player/core/dialogs/index.dart';
import 'package:music_player/core/messages/index.dart';
import 'package:music_player/core/models/song_file.dart';
import 'package:music_player/core/services/song_service.dart';
import 'package:music_player/components/global/audio_form.dart';
import 'package:music_player/components/global/topbar.dart';

class MyPlayer extends StatefulWidget {
  final List<SongFile> songList;
  final int initialIndex;
  final String title;
  final VoidCallback? refresh;

  const MyPlayer({
    super.key,
    required this.songList,
    required this.initialIndex,
    required this.title,
    this.refresh,
  });

  @override
  State<MyPlayer> createState() => _MyPlayerState();
}

class _MyPlayerState extends State<MyPlayer> {
  final AudioPlayer _player = AudioPlayer();
  final service = SongService();
  late int currentIndex;
  late List<SongFile> songList; // Mutable playlist in state
  late List<SongFile> originalSongList; // Keep the original order
  bool isLooping = false;
  bool isShuffled = false; // New flag to track shuffle mode

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    originalSongList = List.from(widget.songList); // Store the original order
    songList = List.from(widget.songList); // Mutable copy for sorting/shuffling
    _init();

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (currentIndex < widget.songList.length - 1) {
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
      if (songList[currentIndex].url.startsWith('assets/')) {
        await _player.setAudioSource(
          AudioSource.asset(songList[currentIndex].url),
        );
      } else {
        await _player.setAudioSource(
          AudioSource.file(songList[currentIndex].url),
        );
      }

      _player.seek(Duration.zero); // Reset position to 0
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

  void goToNext() {
    if (currentIndex < widget.songList.length - 1) {
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

  Future<void> removeSong(String id) async {
    await service.removeFrom(id);
  }

  Future<void> addToPlaylist(String id, String playlistName) async {
    await service
        .addToPlaylist(id: id, name: playlistName, reload: widget.refresh)
        .then((val) {
          if (val == playlistName) {
            Msg.showInfo(
              title: 'Playlist Existing',
              message: 'The $playlistName have already!',
            );
          } else if (val != playlistName) {
            Get.back();
            Msg.showSuccess(
              title: 'Add Playlist',
              message: 'Added to $playlistName!',
            );
          }
        });
  }

  Future<void> removeFromPlaylist(String id, String playlistName) async {
    await service
        .removeFromPlaylist(id: id, name: playlistName, reload: widget.refresh)
        .then((_) {
          Get.back();
          Msg.showSuccess(
            title: 'Remove',
            message: 'Removed from $playlistName',
          );
        });
  }

  // New method to toggle between sorted and random playback
  void togglePlaybackMode() {
    setState(() {
      isShuffled = !isShuffled;
      if (isShuffled) {
        // Shuffle the playlist
        songList.shuffle();
        // Find the current song's new index after shuffling
        final currentSong = originalSongList[currentIndex];
        currentIndex = songList.indexOf(currentSong);
      } else {
        // Restore the sorted order (e.g., by title)
        songList = List.from(originalSongList);
        songList.sort((a, b) => a.title.compareTo(b.title));
        // Find the current song's new index after sorting
        final currentSong = originalSongList[currentIndex];
        currentIndex = songList.indexOf(currentSong);
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
    final currentAudio = songList[currentIndex];

    return SafeArea(
      child: Topbar(
        backIcon: false,
        pressed: widget.refresh,
        title: "Music from ${widget.title}",
        content: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImgAsset(
                path: currentAudio.artworkUrl,
                heightFraction: 0.4,
                widthFraction: 1,
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
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_document),
                    onPressed: () {
                      AudioForm.showForm(
                        context,
                        model: currentAudio,
                        reload: widget.refresh,
                      );
                    },
                    tooltip: "Modify Existing",
                  ),

                  IconButton(
                    icon: Icon(
                      currentAudio.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: currentAudio.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () async {
                      await service.toggleFavorite(currentAudio.id);

                      // Optionally, fetch the updated song if needed
                      final updatedAudio = await service.getSongById(
                        currentAudio.id,
                      );

                      setState(() {
                        // Update the playlist with the new favorite status
                        songList[currentIndex] = updatedAudio!;
                      });
                    },
                    tooltip: "Add to Favorite",
                  ),
                  Spacer(),

                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Popup.confirmDelete(
                        context,
                        message: currentAudio.title,
                        refresh: widget.refresh,
                        confirmed: () async {
                          await service.removeFrom(currentAudio.id);
                        },
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      await addToPlaylist(currentAudio.id, value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'My Playlist',
                        child: Text('Add to My Playlist'),
                      ),
                      const PopupMenuItem(
                        value: 'Your Playlist',
                        child: Text('Add to Your Playlist'),
                      ),
                      const PopupMenuItem(
                        value: 'Our Playlist',
                        child: Text('Add to Our Playlist'),
                      ),
                    ],
                    icon: Icon(Icons.playlist_add),
                    tooltip: "Add To Playlist",
                  ),

                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      await removeFromPlaylist(currentAudio.id, value);
                    },
                    itemBuilder: (_) => currentAudio.playlists
                        .map((playlist) {
                          if (playlist.isNotEmpty) {
                            return PopupMenuItem<String>(
                              value: playlist,
                              child: Text('Remove from $playlist'),
                            );
                          }
                          return null;
                        })
                        .whereType<PopupMenuItem<String>>()
                        .toList(),
                    icon: const Icon(Icons.playlist_remove),
                    tooltip: "Remove From Playlist",
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
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
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
                      color: currentIndex < songList.length - 1
                          ? null
                          : Colors.grey,
                    ),
                    onPressed: currentIndex < songList.length - 1
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
    );
  }
}
