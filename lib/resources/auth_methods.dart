import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fullstack_instagram_clone/model/user.dart' as model;
import 'package:fullstack_instagram_clone/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.UserModel> getUsersDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.UserModel.fromSnap(snap);
  }

  Future<String> singUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
    BuildContext? context,
  }) async {
    String res = "some error occurred";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        print("User UID: ${cred.user!.uid}");

        String base64Image = base64Encode(file);
        String imageDataUrl = 'data:image/jpeg;base64,$base64Image';

        // tambah user ke firebase
        model.UserModel user = model.UserModel(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          photoUrl: imageDataUrl,
          following: [],
          followers: [],
        );

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());

        // Refresh user provider setelah signup berhasil
        if (context != null && context.mounted) {
          try {
            await Provider.of<UserProvider>(
              context,
              listen: false,
            ).refreshUser();
          } catch (e) {
            print("Error refreshing user after signup: $e");
          }
        }

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

  // handle login - dengan context untuk refresh provider
  Future<String> loginUser({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    String res = "validasi error";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // Fixed: should be AND not OR
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Refresh user provider setelah login berhasil
        if (context != null && context.mounted) {
          try {
            await Provider.of<UserProvider>(
              context,
              listen: false,
            ).refreshUser();
            print("User provider refreshed after login");
          } catch (e) {
            print("Error refreshing user after login: $e");
          }
        }

        res = "success";
      } else {
        res = 'tolong isi input';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // handle login tanpa context (untuk backward compatibility)
  Future<String> loginUserSimple({
    required String email,
    required String password,
  }) async {
    String res = "validasi error";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = 'tolong isi input';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut({BuildContext? context}) async {
    await _auth.signOut();

    // Clear user provider setelah logout
    if (context != null && context.mounted) {
      try {
        Provider.of<UserProvider>(context, listen: false).clearUser();
        print("User provider cleared after logout");
      } catch (e) {
        print("Error clearing user after logout: $e");
      }
    }
  }
}
