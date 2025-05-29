import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:music_player/core/services/service.dart';

class Funcs extends Service {
  //image path
  static var imagePath = "";
  static final picker = ImagePicker();

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
