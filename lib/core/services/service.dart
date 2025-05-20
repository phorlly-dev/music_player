import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Service {
  static final firestore = FirebaseFirestore.instance;
  // var result = FilePicker.platform.pickFiles();
  //for upload image files

  /// Create (Add) a new document with auto ID
  static Future<String> create<T>({
    required T model,
    required String collectionName,
    required Map<String, dynamic> Function(T model) toMap,
  }) async {
    final docRef = firestore.collection(collectionName).doc();
    final data = toMap(model);

    data['id'] = docRef.id;
    await docRef.set(data);

    return docRef.id;
  }

  /// Read all documents from a collection
  static Future<List<T>> readAll<T>({
    required String collectionName,
    required T Function(Map<String, dynamic> data, String docId) fromMap,
  }) async {
    final snapshot = await firestore.collection(collectionName).get();

    return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
  }

  /// Stream documents in real-time
  static Stream<List<T>> streamAll<T>({
    required String collectionName,
    required T Function(Map<String, dynamic> data, String docId) fromMap,
  }) {
    return firestore.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Update an existing document by ID
  static Future<void> update({
    required String collectionName,
    required String docId,
    required Map<String, dynamic> toMap,
  }) async {
    await firestore.collection(collectionName).doc(docId).update(toMap);
  }

  /// Delete a document by ID
  static Future<void> delete({
    required String collectionName,
    required String docId,
  }) async {
    await firestore.collection(collectionName).doc(docId).delete();
  }

  /// Get a single document by ID
  static Future<T?> readOne<T>({
    required String collectionName,
    required String docId,
    required T Function(Map<String, dynamic> data, String docId) fromMap,
  }) async {
    final doc = await firestore.collection(collectionName).doc(docId).get();

    if (doc.exists) {
      return fromMap(doc.data()!, doc.id);
    }

    return null;
  }

  //Stream builder for reuseable widget
  static StreamBuilder<List<T>> streamBuilder<T>({
    required String collectionName,
    required T Function(Map<String, dynamic> data, String docId) fromMap,
    required Widget Function(BuildContext context, List<T> data) builder,
  }) {
    return StreamBuilder<List<T>>(
      stream: streamAll(collectionName: collectionName, fromMap: fromMap),
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

  static Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<void> writeFile(String fileName, String content) async {
    final path = await localPath();
    final file = File('$path/$fileName');

    await file.writeAsString(content);

    log('The file: $file');
  }

  static Future<String> readFile(String fileName) async {
    try {
      final path = await localPath();
      final file = File('$path/$fileName');

      return await file.readAsString();
    } catch (e) {
      return 'Error reading file: $e';
    }
  }

  static Future<String> imagePickup({isCamera = true}) async {
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

  static Future<void> copyFromCacheToAppFolder(String fullCachePath) async {
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

  static Future<void> addFileToFolder(
    String sourceFilePath,
    String folderName,
  ) async {
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
