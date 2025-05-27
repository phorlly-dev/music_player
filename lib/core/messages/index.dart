import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  static showError({
    String title = 'Error',
    String message = 'An error occurred!',
    Color bgColor = Colors.red,
  }) {
    return Get.snackbar(title, message, backgroundColor: bgColor);
  }

  static showSuccess({
    String title = 'Success',
    String message = 'Operation successful!',
    Color bgColor = Colors.green,
  }) {
    return Get.snackbar(
      title,
      message,
      maxWidth: 260,
      backgroundColor: bgColor,
      icon: Icon(Icons.check_box_rounded),
    );
  }

  static showWarning({
    String title = 'Warning',
    String message = 'This is a warning!',
    Color bgColor = Colors.orange,
  }) {
    return Get.snackbar(
      title,
      message,
      backgroundColor: bgColor,
      maxWidth: 260,
    );
  }

  static showInfo({
    String title = 'Info',
    String message = 'Here is some information.',
    Color bgColor = Colors.blueGrey,
  }) {
    return Get.snackbar(
      title,
      message,
      backgroundColor: bgColor,
      maxWidth: 260,
      icon: Icon(Icons.info_outlined),
    );
  }
}
