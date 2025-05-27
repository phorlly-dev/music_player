import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/components/global/sample.dart';
import 'package:music_player/core/functions/index.dart';
import 'package:music_player/core/messages/index.dart';
import 'package:music_player/core/models/song_file.dart';
import 'package:music_player/core/services/song_service.dart';

class SongFormDialog extends StatefulWidget {
  final SongFile? model;
  final VoidCallback? reload;

  const SongFormDialog({super.key, this.model, this.reload});

  @override
  State<SongFormDialog> createState() => _SongFormDialogState();
}

class _SongFormDialogState extends State<SongFormDialog> {
  //assign a global key to the form
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  String? _audioPath;
  String? _imagePath;
  final SongService service = SongService();

  // Initialize the controllers with existing values if available
  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _titleController.text = widget.model!.title;
      _artistController.text = widget.model!.artist;
      _albumController.text = widget.model!.album;
      _audioPath = widget.model!.url; // Initialize with existing audio path
      _imagePath =
          widget.model!.artworkUrl; // Initialize with existing image path
    }
  }

  //pick audio file
  Future<void> _pickAudioFile() async {
    await Funcs().pickFile(isImage: false).then((value) {
      setState(() {
        _audioPath = value;
      });
    });
  }

  //pick image file
  Future<void> _pickImageFile() async {
    await Funcs().pickFile().then((value) {
      setState(() {
        _imagePath = value;
      });
    });
  }

  // Function to get audio duration using just_audio and fallback to flutter_media_metadata
  Future<Duration> getAudioDuration(String path) async {
    final player = AudioPlayer();
    try {
      log('Attempting to load audio file with just_audio: $path');
      final file = File(path);
      if (!await file.exists()) {
        log('File does not exist at $path');
        return Duration.zero;
      }
      log('File exists, size: ${await file.length()} bytes');
      await player.setAudioSource(AudioSource.file(path));
      log('Audio file loaded successfully with just_audio');
      final duration = player.duration ?? Duration.zero;

      return duration;
    } catch (e) {
      log('just_audio failed to load $path: $e');
      // Fallback to flutter_media_metadata
      try {
        log('Attempting to retrieve duration with flutter_media_metadata');
        final metadata = await MetadataRetriever.fromFile(File(path));
        final durationSeconds = metadata.trackDuration?.toInt() ?? 0;
        log(
          'Duration retrieved with flutter_media_metadata: $durationSeconds seconds',
        );
        return Duration(seconds: durationSeconds);
      } catch (metadataError) {
        log(
          'flutter_media_metadata failed to retrieve duration for $path: $metadataError',
        );
        return Duration.zero;
      }
    } finally {
      await player.dispose();
    }
  }

  // Submit the form and save the song
  void _submit() async {
    if (_formKey.currentState!.validate() && _audioPath != null) {
      try {
        // Determine if audio or image files have changed
        final isAudioUnchanged =
            widget.model != null && _audioPath == widget.model!.url;
        final isImageUnchanged =
            widget.model != null && _imagePath == widget.model!.artworkUrl;

        String newAudioPath, newImagePath;
        // Delete old files if they exist and new files are selected
        if (widget.model != null) {
          if (!isAudioUnchanged && widget.model!.url.isNotEmpty) {
            final oldmodel = File(widget.model!.url);
            if (await oldmodel.exists()) {
              await oldmodel.delete();
              log('Deleted old audio file: ${widget.model!.url}');
            }
          }
          if (!isImageUnchanged && widget.model!.artworkUrl.isNotEmpty) {
            final oldImageFile = File(widget.model!.artworkUrl);
            if (await oldImageFile.exists()) {
              await oldImageFile.delete();
              log('Deleted old image file: ${widget.model!.artworkUrl}');
            }
          }
        }

        // Copy new files only if they have changed
        newAudioPath = isAudioUnchanged
            ? _audioPath!
            : await service.copyFileToAppStorage(_audioPath!);
        newImagePath = _imagePath != null
            ? (isImageUnchanged
                  ? _imagePath!
                  : await service.copyFileToAppStorage(_imagePath!))
            : '';

        // Retrieve duration only if the audio file has changed
        final duration = isAudioUnchanged
            ? widget
                  .model!
                  .duration // Use existing duration
            : await getAudioDuration(newAudioPath);
        if (duration == Duration.zero && !isAudioUnchanged) {
          log('Warning: Could not retrieve duration for $newAudioPath');
        }

        final newmodel = SongFile(
          id:
              widget.model?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          artist: _artistController.text,
          album: _albumController.text,
          duration: duration,
          url: newAudioPath,
          artworkUrl: newImagePath,
          isFavorite: widget.model?.isFavorite ?? false,
          playlists: widget.model?.playlists ?? [],
        );

        if (widget.model == null) {
          await service.saveTo(newmodel);
        } else {
          await service.releaseTo(newmodel);
        }

        Get.back();
        Get.back();
        widget.reload?.call();
      } catch (e) {
        Msg.showError(
          title: "Error Handler",
          message: 'Failed to save song: $e',
        );
      }
    } else {
      Msg.showError(
        title: 'Validation Error',
        message: 'Please fill all fields and select an audio file.',
      );
    }
  }

  // Dispose of the controllers
  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.model == null ? 'Add Song' : 'Edit Song',
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(labelText: 'Artist'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an artist' : null,
              ),
              TextFormField(
                controller: _albumController,
                decoration: const InputDecoration(labelText: 'Album'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an album' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _audioPath != null
                          ? _audioPath!.split('/').last
                          : 'No audio selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.music_note),
                    onPressed: _pickAudioFile,
                    tooltip: 'Pick Audio File',
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _imagePath != null
                          ? _imagePath!.split('/').last
                          : 'No image selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImageFile,
                    tooltip: 'Pick Image File',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          click: () => Get.back(),
          label: 'Cancel',
          icon: Icons.close,
          color: Colors.black,
        ),
        Button(
          click: _submit,
          label: widget.model == null ? 'Save' : 'Update',
          color: widget.model == null ? Colors.blue : Colors.green,
          icon: widget.model == null ? Icons.save : Icons.update,
        ),
      ],
    );
  }
}
