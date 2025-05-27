import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Funcs {
  //image path
  static var imagePath = "";
  static final picker = ImagePicker();
  static final formKey = GlobalKey<FormState>();

  static bool isSameMinute(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  //for choosing the file to upload
  static Future<String> showFile({isGallery = true}) async {
    // Pick an image.
    final image = await picker.pickImage(
      source: isGallery ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 70,
    );

    if (image != null) {
      // print("Image path: ${image.path} --MimeType: ${image.mimeType}");
      imagePath = image.path;
    }

    return imagePath;
  }

  static String numToStr(int key) {
    return key.toString().padLeft(2, '0');
  }

  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<bool> permission() async {
    var status = await Permission.storage.request();

    return status.isGranted ? true : false;
  }

  Future<String> pickFile({bool isImage = true}) async {
    var path = '';
    if (await permission()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: isImage
            ? ['png', 'jpg', 'jpeg', 'gif', 'svg']
            : ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
      );
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        path = file.path;
      }
    } else {
      Get.snackbar('Upload File', 'Storage permission denied');
    }

    return path;
  }

  Future<String> copyFileToAppStorage(String filePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = filePath.split('/').last;
    final newPath = '${appDir.path}/$fileName';
    await File(filePath).copy(newPath);

    return newPath;
  }

  static dateFormat(DateTime value) {
    return DateFormat('dd_MM_yyyy').format(value);
  }

  static dateTimeFormat(DateTime value) {
    return DateFormat('dd/MM/yyyy, hh:mm a').format(value);
  }

  static void backTo() {
    Get.back();
  }
}
