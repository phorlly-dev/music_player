import 'package:flutter/material.dart';

class Msg {
  static message(
    BuildContext context, {
    String message = 'Posted!',
    Color bgColor = Colors.blue,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        width: 200,
      ),
    );
  }
}
