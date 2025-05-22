import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:music_player/views/music_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Use the default dark theme
      // themeMode: ThemeMode.dark, // Forces dark mode
      // Or customize the dark theme:
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          primary: Colors.white,
          secondary: Colors.grey,
        ),
      ),
      home: const MusicPlayer(),
    );
  }
}
