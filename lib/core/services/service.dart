import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Service {
  final firestore = FirebaseFirestore.instance;
  // var result = FilePicker.platform.pickFiles();
  //for upload image files

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

  static Future<void> storeFile(
    String folderName,
    String fileName,
    String content,
  ) async {
    final directory =
        await getApplicationDocumentsDirectory(); // or getTemporaryDirectory()
    final folderPath = '${directory.path}/$folderName';

    // Create the folder if it doesn't exist
    final folder = Directory(folderPath);
    if (!(await folder.exists())) {
      await folder.create(recursive: true);
    }

    final file = File('$folderPath/$fileName');
    await file.writeAsString(content);

    log('File written to: ${file.path}');
  }

  Future<void> copyFromCacheToAppFolder(String fullCachePath) async {
    final cacheFile = File(fullCachePath);

    if (await cacheFile.exists()) {
      final appDocDir = await localPath();

      final folder = Directory('$appDocDir/assets/images');

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final fileName = p.basename(fullCachePath); // Extract just the filename
      final newPath = '${folder.path}/$fileName';

      await cacheFile.copy(newPath);
      log('File copied to: $newPath');
    } else {
      log('File does not exist at: $fullCachePath');
    }
  }

  Future<void> addFileToFolder(String sourceFilePath, String folderName) async {
    final sourceFile = File(sourceFilePath);

    if (await sourceFile.exists()) {
      // Get app documents directory
      final appDir = await localPath();
      final targetFolder = Directory('$appDir/$folderName');

      // Create folder if it doesn't exist
      if (!await targetFolder.exists()) {
        await targetFolder.create(recursive: true);
      }

      // Get just the file name
      final fileName = p.basename(sourceFilePath);

      // Destination file path
      final destinationPath = '${targetFolder.path}/$fileName';
      await sourceFile.copy(destinationPath);

      log('File added to folder: $destinationPath');
    } else {
      log('Source file does not exist: $sourceFilePath');
    }
  }
}
