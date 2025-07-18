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
    String profilImage,
  ) async {
    String res = "some error occurred";
    try {
      if (uid.isEmpty) return "Error: User ID is required";
      if (username.isEmpty) return "Error: Username is required";

      String photoUrl = 'data:image/jpeg;base64,${base64Encode(file)}';

      String finalprofilImage = profilImage;
      if (profilImage.isEmpty || profilImage.trim().isEmpty) {
        print('profilImage is empty, trying to fetch from user profile...');
        finalprofilImage = await _getUserProfileImage(uid) ?? '';
      }

      print('=== UPLOAD POST DEBUG ===');
      print('uid: $uid');
      print('username: $username');
      print('original profilImage: $profilImage');
      print('final profilImage length: ${finalprofilImage.length}');
      print(
        'final profilImage preview: ${finalprofilImage.length > 50 ? "${finalprofilImage.substring(0, 50)}..." : finalprofilImage}',
      );

      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profilImage: finalprofilImage,
        likes: [],
      );

      Map<String, dynamic> postJson = post.toJson();
      if (postJson['profilImage'] == null) {
        print('Warning: profilImage is null in JSON, setting empty string');
        postJson['profilImage'] = '';
      }

      print('Final post JSON: $postJson');
      await _firestore.collection('posts').doc(postId).set(postJson);

      DocumentSnapshot savedDoc =
          await _firestore.collection('posts').doc(postId).get();
      Map<String, dynamic> savedData = savedDoc.data() as Map<String, dynamic>;
      print('Verified saved profilImage: ${savedData['profilImage']}');

      res = "success";
    } catch (err) {
      print('Error in uploadPost: $err');
      res = err.toString();
    }

    return res;
  }

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

  Future<String> updatePostProfileImage(
    String postId,
    String newprofilImage,
  ) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'profilImage': newprofilImage,
      });
      return "success";
    } catch (e) {
      print('Error updating post profile image: $e');
      return e.toString();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPostsWithEnrichedData() {
    return _firestore
        .collection('posts')
        .orderBy('datePublished', descending: true)
        .snapshots();
  }

  Future<void> fixAllPostsProfileImages() async {
    try {
      QuerySnapshot postsSnapshot =
          await _firestore
              .collection('posts')
              .where('profilImage', whereIn: [null, '', ' '])
              .get();

      for (DocumentSnapshot doc in postsSnapshot.docs) {
        Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
        String uid = postData['uid'] ?? '';

        if (uid.isNotEmpty) {
          String? userProfilImage = await _getUserProfileImage(uid);

          if (userProfilImage != null && userProfilImage.isNotEmpty) {
            await doc.reference.update({'profilImage': userProfilImage});
            print('Updated profilImage for post: ${doc.id}');
          }
        }
      }

      print('Finished fixing profile images for all posts');
    } catch (e) {
      print('Error fixing posts profile images: $e');
    }
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    print("Running likePost for postId: $postId, uid: $uid");
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print('Error while liking/unliking post: $e');
    }
  }

  Future<void> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  }) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();

        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
              'text': text,
              'uid': uid,
              'username': username,
              'profilePic': profilePic,
              'datePublished': DateTime.now(),
            });
      } else {
        print("Komentar kosong!");
      }
    } catch (e) {
      print("Error posting comment: $e");
    }
  }

  // method untuk hapus post
  Future<void> deletePost(String postId) async {
    try {
      // lakukan hapus komentar juga untuk post yang di pilih
      QuerySnapshot comments =
          await _firestore
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .get();

      for (DocumentSnapshot doc in comments.docs) {
        await doc.reference.delete();
      }

      // Hapus dokumen post
      await _firestore.collection('posts').doc(postId).delete();

      print('Post dan komentar berhasil dihapus.');
    } catch (err) {
      print('Error saat menghapus post: $err');
    }
  }
}
