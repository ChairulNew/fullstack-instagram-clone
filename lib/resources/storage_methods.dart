import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // simpan imag profile ke firebase
  Future<String> UploadImageToStorage(String childName, Uint8List file, bool isPost){
    _storage.ref().child(childName)
  }
}
