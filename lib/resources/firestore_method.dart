import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fullstack_instagram_clone/model/post.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "some error occurred";
    try {
      // Validate inputs
      if (uid.isEmpty) {
        return "Error: User ID is required";
      }

      if (username.isEmpty) {
        return "Error: Username is required";
      }

      // Convert image to base64
      String photoUrl = 'data:image/jpeg;base64,${base64Encode(file)}';

      // Handle profImage - jika kosong, coba ambil dari user profile
      String finalProfImage = profImage;
      if (profImage.isEmpty || profImage.trim().isEmpty) {
        print('profImage is empty, trying to fetch from user profile...');
        finalProfImage = await _getUserProfileImage(uid) ?? '';
      }

      // Debug prints
      print('=== UPLOAD POST DEBUG ===');
      print('uid: $uid');
      print('username: $username');
      print('original profImage: $profImage');
      print('final profImage length: ${finalProfImage.length}');
      print(
        'final profImage preview: ${finalProfImage.length > 50 ? finalProfImage.substring(0, 50) + "..." : finalProfImage}',
      );
      print('========================');

      String postId = const Uuid().v1();

      // Create post object
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage:
            finalProfImage, // Gunakan finalProfImage yang sudah divalidasi
        likes: [],
      );

      // Convert to JSON and validate
      Map<String, dynamic> postJson = post.toJson();

      // Validate crucial fields before saving
      if (postJson['profImage'] == null) {
        print('Warning: profImage is null in JSON, setting empty string');
        postJson['profImage'] = '';
      }

      // Debug print final JSON
      print('Final post JSON: $postJson');

      // Save to Firestore
      await _firestore.collection('posts').doc(postId).set(postJson);

      // Verify the saved data
      DocumentSnapshot savedDoc =
          await _firestore.collection('posts').doc(postId).get();
      Map<String, dynamic> savedData = savedDoc.data() as Map<String, dynamic>;
      print('Verified saved profImage: ${savedData['profImage']}');

      res = "success";
    } catch (err) {
      print('Error in uploadPost: $err');
      res = err.toString();
    }

    return res;
  }

  /// Fungsi untuk mengambil profile image dari user collection
  Future<String?> _getUserProfileImage(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? photoUrl = userData['photoUrl'] as String?;

        print('Found user photoUrl: $photoUrl');
        return photoUrl;
      } else {
        print('User document not found for uid: $uid');
      }
    } catch (e) {
      print('Error fetching user profile image: $e');
    }

    return null;
  }

  /// Fungsi helper untuk update profImage pada post yang sudah ada
  Future<String> updatePostProfileImage(
    String postId,
    String newProfImage,
  ) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'profImage': newProfImage,
      });
      return "success";
    } catch (e) {
      print('Error updating post profile image: $e');
      return e.toString();
    }
  }

  /// Fungsi untuk mengambil semua posts dengan enriched data
  Stream<QuerySnapshot<Map<String, dynamic>>> getPostsWithEnrichedData() {
    return _firestore
        .collection('posts')
        .orderBy('datePublished', descending: true)
        .snapshots();
  }

  /// Fungsi untuk fix semua posts yang memiliki profImage kosong
  Future<void> fixAllPostsProfileImages() async {
    try {
      QuerySnapshot postsSnapshot =
          await _firestore
              .collection('posts')
              .where('profImage', whereIn: [null, '', ' '])
              .get();

      for (DocumentSnapshot doc in postsSnapshot.docs) {
        Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
        String uid = postData['uid'] ?? '';

        if (uid.isNotEmpty) {
          String? userProfImage = await _getUserProfileImage(uid);

          if (userProfImage != null && userProfImage.isNotEmpty) {
            await doc.reference.update({'profImage': userProfImage});
            print('Updated profImage for post: ${doc.id}');
          }
        }
      }

      print('Finished fixing profile images for all posts');
    } catch (e) {
      print('Error fixing posts profile images: $e');
    }
  }
}
