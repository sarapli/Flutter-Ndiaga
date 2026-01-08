import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  Future<String?> pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: kIsWeb);
    if (result == null) return null;
    final uid = _auth.currentUser?.uid ?? 'anonymous';
    final ext = result.files.single.extension ?? 'jpg';
    final name = _uuid.v4();
    final path = 'image/$uid/$name.$ext';
    if (kIsWeb) {
      final bytes = result.files.single.bytes!;
      return _uploadBytes(bytes, path, contentType: 'image/$ext');
    } else {
      final filePath = result.files.single.path!;
      return _uploadFile(File(filePath), path, contentType: 'image/$ext');
    }
  }

  Future<String?> pickAndUploadVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video, withData: kIsWeb);
    if (result == null) return null;
    final uid = _auth.currentUser?.uid ?? 'anonymous';
    final ext = result.files.single.extension ?? 'mp4';
    final name = _uuid.v4();
    final path = 'video/$uid/$name.$ext';
    if (kIsWeb) {
      final bytes = result.files.single.bytes!;
      return _uploadBytes(bytes, path, contentType: 'video/$ext');
    } else {
      final filePath = result.files.single.path!;
      return _uploadFile(File(filePath), path, contentType: 'video/$ext');
    }
  }

  Future<String?> _uploadFile(File file, String path, {String? contentType}) async {
    final ref = _storage.ref().child(path);
    final meta = SettableMetadata(contentType: contentType);
    await ref.putFile(file, meta);
    return ref.getDownloadURL();
  }

  Future<String?> _uploadBytes(Uint8List data, String path, {String? contentType}) async {
    final ref = _storage.ref().child(path);
    final meta = SettableMetadata(contentType: contentType);
    await ref.putData(data, meta);
    return ref.getDownloadURL();
  }

  // Optional: store a local copy
  Future<File> saveTemp(Uint8List bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    return file.writeAsBytes(bytes, flush: true);
  }
}
