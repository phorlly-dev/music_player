import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_player/core/functions/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

abstract class Service {
  final firestore = FirebaseFirestore.instance;

  void onInit() {
    // Default implementation (empty)
  }

  void onClose() {
    // Default implementation (empty)
  }

  /// Create (Add) a new document with auto ID
  Future<String> poster<T>({
    required T model,
    required String collection,
    required Map<String, dynamic> Function(T model) toMap,
  }) async {
    final docRef = firestore.collection(collection).doc();
    final data = toMap(model);

    data['id'] = docRef.id;
    await docRef.set(data);

    return docRef.id;
  }

  /// Read all documents from a collection
  Future<List<T>> geter<T>({
    required String collection,
    required T Function(Map<String, dynamic> data, String docId) fromMap,
  }) async {
    final snapshot = await firestore.collection(collection).get();

    return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
  }

  /// Stream documents in real-time
  Stream<List<T>> streamer<T>({
    required String collection,
    required T Function(Map<String, dynamic> data, String docId) fromMap,
  }) {
    return firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Update an existing document by ID
  Future<void> puter({
    required String collection,
    required String docId,
    required Map<String, dynamic> toMap,
  }) async {
    await firestore.collection(collection).doc(docId).update(toMap);
  }

  /// Delete a document by ID
  Future<void> deleter({
    required String collection,
    required String docId,
  }) async {
    await firestore.collection(collection).doc(docId).delete();
  }

  /// Get a single document by ID
  Future<T?> header<T>({
    required String collection,
    required String docId,
    required T Function(Map<String, dynamic> data, String docId) fromMap,
  }) async {
    final doc = await firestore.collection(collection).doc(docId).get();

    if (doc.exists) {
      return fromMap(doc.data()!, doc.id);
    }

    return null;
  }

  //Stream builder for reuseable widget
  StreamBuilder<List<T>> streamBuilder<T>({
    required String collection,
    required T Function(Map<String, dynamic> data, String docId) fromMap,
    required Widget Function(BuildContext context, List<T> data) builder,
  }) {
    return StreamBuilder<List<T>>(
      stream: streamer(collection: collection, fromMap: fromMap),
      builder: (context, snapshot) {
        // log('snapshot: ${snapshot.data}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data found'));
        } else {
          return builder(context, snapshot.data!);
        }
      },
    );
  }

  Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<void> writeFile(String fileName, String content) async {
    final path = await localPath();
    final file = File('$path/$fileName');

    await file.writeAsString(content);

    log('The file: $file');
  }

  Future<String> readFile(String fileName) async {
    try {
      final path = await localPath();
      final file = File('$path/$fileName');

      return await file.readAsString();
    } catch (e) {
      return 'Error reading file: $e';
    }
  }

  Future<String> imagePickup({isCamera = true}) async {
    String path = '';
    final ImagePicker picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedFile != null) {
        path = pickedFile.path;

        return path;
      } else {
        return 'No image selected: $path';
      }
    } catch (e) {
      return 'Error reading file: $e';
    }
  }

  // Custom app directory for storing audio and image files
  Future<String> get appDocumentsDir async {
    final directory = await getApplicationDocumentsDirectory();
    final customDir = Directory('${directory.path}/storages');
    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }
    return customDir.path;
  }

  Future<String> copyFileToAppStorage(String sourcePath) async {
    try {
      final appDir = await appDocumentsDir;
      // Get the original filename and extension
      final originalFileName = sourcePath.split('/').last;
      final extension = originalFileName.split('.').last;
      final sanitizedBaseName = Funcs.dateFormat(DateTime.now());
      // Generate a unique filename using a timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${sanitizedBaseName}_$timestamp.$extension';
      final destinationPath = '$appDir/$uniqueFileName';

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $sourcePath');
      }
      // log('Source file size: ${await sourceFile.length()} bytes');

      // Skip copying if source and destination are the same
      if (sourcePath == destinationPath) {
        // log('Source and destination are the same: $sourcePath');
        return sourcePath;
      }

      final copiedFile = await sourceFile.copy(destinationPath);
      if (!await copiedFile.exists()) {
        throw Exception('Failed to copy file to $destinationPath');
      }
      // log('Copied file to: $destinationPath');
      // log('Copied file size: ${await copiedFile.length()} bytes');

      if (await sourceFile.length() != await copiedFile.length()) {
        throw Exception('File size mismatch after copying');
      }

      return destinationPath;
    } catch (e) {
      throw Exception('Error copying file: $e');
    }
  }
}
