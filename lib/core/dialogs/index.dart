import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/global/sample.dart';

class Popup {
  static confirmDelete(
    BuildContext context, {
    required String message,
    required VoidCallback confirmed,
    VoidCallback? refresh,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete!', textAlign: TextAlign.center),
          content: Text('Are you sure?\n You want to delete: $message?'),
          actions: [
            Button(
              click: () => Get.back(),
              label: 'Cancel',
              icon: Icons.close,
              color: Colors.black,
            ),
            Button(
              click: () {
                confirmed.call();
                refresh?.call();
                Get.back();
              },
              label: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
            ),
          ],
        );
      },
    );
  }

  static showModal({
    required BuildContext context,
    required Widget Function(BuildContext context, StateSetter setState)
    builder,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => builder(context, setState),
        );
      },
    );
  }
}
