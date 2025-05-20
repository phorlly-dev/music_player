import 'package:flutter/material.dart';
import 'package:music_player/components/index.dart';

class Popup {
  static confirmDelete(
    BuildContext context, {
    required String message,
    required VoidCallback confirmed,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete!', textAlign: TextAlign.center),
          content: Text('Are you sure you want to delete:\n $message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Common.text('Cancel'),
            ),
            TextButton(
              onPressed: confirmed,
              child: Common.text('Delete', color: Colors.red),
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
