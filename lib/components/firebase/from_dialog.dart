import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/global/index.dart';
import 'package:music_player/core/messages/index.dart';
import 'package:music_player/core/models/audio_file.dart';
import 'package:music_player/core/services/music_service.dart';

class AudioFormDialog extends StatefulWidget {
  final AudioFile? model;
  const AudioFormDialog({super.key, this.model});

  @override
  State<AudioFormDialog> createState() => _AudioFormDialogState();
}

class _AudioFormDialogState extends State<AudioFormDialog> {
  final title = TextEditingController();
  final artist = TextEditingController();
  final album = TextEditingController();
  final url = TextEditingController();
  final imgUrl = TextEditingController();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    if (widget.model != null) {
      title.text = widget.model!.title;
      artist.text = widget.model!.artist;
      album.text = widget.model!.album;
      url.text = widget.model!.url;
      imgUrl.text = widget.model!.artworkUrl;
      isFavorite = widget.model!.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Controls.form(
      model: widget.model,
      context,
      title: 'Song',
      children: [
        TextFormField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: (value) => value!.isEmpty ? 'Enter title' : null,
        ),
        TextFormField(
          controller: artist,
          decoration: const InputDecoration(labelText: 'Artist'),
          validator: (value) => value!.isEmpty ? 'Enter artist' : null,
        ),
        TextFormField(
          controller: album,
          decoration: const InputDecoration(labelText: 'Album'),
          validator: (value) => value!.isEmpty ? 'Enter Album' : null,
        ),

        // TextFormField(
        //   controller: duration,
        //   decoration: const InputDecoration(labelText: 'Duration (mm:ss)'),
        //   validator:
        //       (value) => value!.contains(':') ? null : 'Format: mm:ss',
        // ),
        widget.model == null
            ? TextFormField(
                controller: url,
                decoration: const InputDecoration(labelText: 'Audio URL'),
                validator: (value) => value!.isEmpty ? 'Enter URL' : null,
              )
            : Text(''),
        // const SizedBox(height: 12),
        widget.model == null
            ? TextFormField(
                controller: imgUrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) => value!.isEmpty ? 'Enter URL' : null,
              )
            : Text(''),
        // const SizedBox(height: 12),

        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     const Text('Artwork Image', style: TextStyle(fontSize: 16)),
        //     const SizedBox(height: 8),
        //     Row(
        //       children: [
        //         IconButton(
        //           onPressed: () async {
        //             await Service.imagePickup(isCamera: false).then((val) {
        //               setState(() => artworkImage = val);
        //               log("Picked file path: $artworkImage");
        //             });
        //           },
        //           icon: Icon(
        //             Icons.image_rounded,
        //             color: Colors.blue,
        //             size: 26,
        //           ),
        //         ),
        //         IconButton(
        //           onPressed: () async {
        //             await Service.imagePickup().then((val) {
        //               setState(() => artworkImage = val);
        //               log("Picked file path: $artworkImage");
        //             });
        //           },
        //           icon: Icon(
        //             Icons.camera_alt_outlined,
        //             color: Colors.blue,
        //             size: 26,
        //           ),
        //         ),
        //         Spacer(),
        //         ImageFile(image: artworkImage, w: 80, h: 100),
        //       ],
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 12),
        SwitchListTile(
          value: isFavorite,
          onChanged: (val) => setState(() => isFavorite = val),
          title: const Text('Favorite'),
        ),
      ],

      onSave: () async {
        await MusicService().store(
          AudioFile(
            id: "",
            title: title.text,
            artist: artist.text,
            album: album.text,
            duration: Duration(minutes: 3, seconds: 45),
            url: url.text,
            artworkUrl: imgUrl.text,
            isFavorite: isFavorite,
          ),
        );

        if (context.mounted) {
          Get.back();
          Msg.message(context, message: 'Created successfully!');
        }
      },

      // Update button
      onUpdate: () async {
        await MusicService().update(
          AudioFile(
            id: widget.model!.id,
            title: title.text,
            artist: artist.text,
            album: album.text,
            duration: Duration(minutes: 3, seconds: 45),
            url: url.text,
            artworkUrl: imgUrl.text,
            isFavorite: isFavorite,
          ),
        );

        if (context.mounted) {
          Get.back();
          Get.back();
          Msg.message(
            context,
            message: 'Updated successfully!',
            bgColor: Colors.green,
          );
        }
      },
    );
  }
}
