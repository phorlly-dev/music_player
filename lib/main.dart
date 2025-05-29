import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:music_player/views/music_player.dart';
import 'package:music_player/views/song_player.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // NOTE: Replace with your own app ID from https://www.onesignal.com
  OneSignal.initialize("85e46b10-14e0-48a1-bc03-ced909ff21da");
  OneSignal.Notifications.requestPermission(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Get.isDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Get.isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: Get.isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return GetMaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Default light theme
      darkTheme: ThemeData.dark(), // Dark theme
      themeMode: ThemeMode.system, // Follow system or allow toggling
      // home: const MusicPlayer(),
      home: const SongPlayer(),
    );
  }
}
