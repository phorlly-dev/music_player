import 'package:flutter/material.dart';
import 'package:music_player/components/firebase/from_dialog.dart';
import 'package:music_player/components/sql/media_form.dart';
import 'package:music_player/core/models/audio_file.dart';
import 'package:music_player/core/models/song_file.dart';

class AudioForm {
  // Function to show the form dialog for adding/editing a user
  static void showForm(
    BuildContext context, {
    SongFile? model,
    VoidCallback? reload,
  }) {
    showDialog(
      context: context,
      builder: (_) => SongFormDialog(model: model, reload: reload),
    );
  }

  static void showFormTo(BuildContext context, AudioFile? model) {
    showDialog(
      context: context,
      builder: (_) {
        return AudioFormDialog(model: model);

        //     final title = TextEditingController(text: model?.title ?? '');
        //     final artist = TextEditingController(text: model?.artist ?? '');
        //     final album = TextEditingController(text: model?.album ?? '');
        //     final url = TextEditingController(text: model?.url ?? '');
        //     final imgUrl = TextEditingController(text: model?.artworkUrl ?? '');

        //     // final duration = TextEditingController(
        //     //   text:
        //     //       model?.duration != null
        //     //           ? model!.duration.toString()
        //     //           : Duration(milliseconds: 0).toString(),
        //     // );
        //     bool isFavorite = model?.isFavorite ?? false;
        //     // String artworkImage = '';

        //     // Show the dialog
        //     return Popup.showModal(
        //       context: context,
        //       builder: (context, setState) {
        //         return Controls.form(
        //           model: model,
        //           context,
        //           title: 'Song',
        //           children: [
        //             TextFormField(
        //               controller: title,
        //               decoration: const InputDecoration(labelText: 'Title'),
        //               validator: (value) => value!.isEmpty ? 'Enter title' : null,
        //             ),
        //             TextFormField(
        //               controller: artist,
        //               decoration: const InputDecoration(labelText: 'Artist'),
        //               validator: (value) => value!.isEmpty ? 'Enter artist' : null,
        //             ),
        //             TextFormField(
        //               controller: album,
        //               decoration: const InputDecoration(labelText: 'Album'),
        //               validator: (value) => value!.isEmpty ? 'Enter Album' : null,
        //             ),

        //             // TextFormField(
        //             //   controller: duration,
        //             //   decoration: const InputDecoration(labelText: 'Duration (mm:ss)'),
        //             //   validator:
        //             //       (value) => value!.contains(':') ? null : 'Format: mm:ss',
        //             // ),
        //             model == null
        //                 ? TextFormField(
        //                     controller: url,
        //                     decoration: const InputDecoration(
        //                       labelText: 'Audio URL',
        //                     ),
        //                     validator: (value) =>
        //                         value!.isEmpty ? 'Enter URL' : null,
        //                   )
        //                 : Text(''),
        //             // const SizedBox(height: 12),
        //             model == null
        //                 ? TextFormField(
        //                     controller: imgUrl,
        //                     decoration: const InputDecoration(
        //                       labelText: 'Image URL',
        //                     ),
        //                     validator: (value) =>
        //                         value!.isEmpty ? 'Enter URL' : null,
        //                   )
        //                 : Text(''),
        //             // const SizedBox(height: 12),

        //             // Column(
        //             //   crossAxisAlignment: CrossAxisAlignment.start,
        //             //   children: [
        //             //     const Text('Artwork Image', style: TextStyle(fontSize: 16)),
        //             //     const SizedBox(height: 8),
        //             //     Row(
        //             //       children: [
        //             //         IconButton(
        //             //           onPressed: () async {
        //             //             await Service.imagePickup(isCamera: false).then((val) {
        //             //               setState(() => artworkImage = val);
        //             //               log("Picked file path: $artworkImage");
        //             //             });
        //             //           },
        //             //           icon: Icon(
        //             //             Icons.image_rounded,
        //             //             color: Colors.blue,
        //             //             size: 26,
        //             //           ),
        //             //         ),
        //             //         IconButton(
        //             //           onPressed: () async {
        //             //             await Service.imagePickup().then((val) {
        //             //               setState(() => artworkImage = val);
        //             //               log("Picked file path: $artworkImage");
        //             //             });
        //             //           },
        //             //           icon: Icon(
        //             //             Icons.camera_alt_outlined,
        //             //             color: Colors.blue,
        //             //             size: 26,
        //             //           ),
        //             //         ),
        //             //         Spacer(),
        //             //         ImageFile(image: artworkImage, w: 80, h: 100),
        //             //       ],
        //             //     ),
        //             //   ],
        //             // ),
        //             // const SizedBox(height: 12),
        //             SwitchListTile(
        //               value: isFavorite,
        //               onChanged: (val) => setState(() => isFavorite = val),
        //               title: const Text('Favorite'),
        //             ),
        //           ],

        //           // Save button
        //           onSave: () async {
        //             await MusicService().store(
        //               AudioFile(
        //                 id: "",
        //                 title: title.text,
        //                 artist: artist.text,
        //                 album: album.text,
        //                 duration: Duration(minutes: 3, seconds: 45),
        //                 url: url.text,
        //                 artworkUrl: imgUrl.text,
        //                 isFavorite: isFavorite,
        //               ),
        //             );

        //             if (context.mounted) {
        //               Get.back();
        //               Msg.message(context, message: 'Created successfully!');
        //             }
        //           },

        //           // Update button
        //           onUpdate: () async {
        //             await MusicService().update(
        //               AudioFile(
        //                 id: model!.id,
        //                 title: title.text,
        //                 artist: artist.text,
        //                 album: album.text,
        //                 duration: Duration(minutes: 3, seconds: 45),
        //                 url: url.text,
        //                 artworkUrl: imgUrl.text,
        //                 isFavorite: isFavorite,
        //               ),
        //             );

        //             if (context.mounted) {
        //               Get.back();
        //               Get.back();
        //               Msg.message(
        //                 context,
        //                 message: 'Updated successfully!',
        //                 bgColor: Colors.green,
        //               );
        //             }
        //           },
        //         );
        //       },
        //     );
      },
    );
  }
}
