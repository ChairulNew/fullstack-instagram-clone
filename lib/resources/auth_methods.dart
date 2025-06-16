import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> singUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "some error occurred";
    try {
      // Perbaikan logika kondisi - seharusnya AND (&&) bukan OR (||)
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        // Lakukan registrasi
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        print("User UID: ${cred.user!.uid}");

        // Convert image ke Base64 string untuk disimpan di Firestore
        String base64Image = base64Encode(file);
        String imageDataUrl = 'data:image/jpeg;base64,$base64Image';

        // Add user to database dengan image sebagai Base64
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'username': username,
          'uid': cred.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': [],
          'photoUrl': imageDataUrl, // Simpan sebagai data URL
        });

        res = 'success';
      } else {
        res = 'Please fill all the fields';
      }
    } catch (err) {
      res = err.toString();
      print("Error during signup: $err");
    }
    return res;
  }
}
