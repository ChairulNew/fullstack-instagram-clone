import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fullstack_instagram_clone/providers/user_provider.dart';
import 'package:fullstack_instagram_clone/resources/firestore_method.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  void postComment(user) async {
    await FirestoreMethods().postComment(
      postId: widget.postId,
      text: _commentController.text,
      uid: user.uid,
      username: user.username,
      profilePic: user.photoUrl,
    );

    setState(() {
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text("Komentar"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .orderBy('datePublished', descending: true)
                      .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var comment = snapshot.data!.docs[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: _buildProfileImage(
                          comment['profilePic'],
                        ),
                      ),
                      title: Text(comment['username']),
                      subtitle: Text(comment['text']),
                      trailing: Text(
                        DateFormat.yMMMd().format(
                          (comment['datePublished'] as Timestamp).toDate(),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: _buildProfileImage(user!.photoUrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Tulis komentar...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => postComment(user),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _buildProfileImage(String? imageString) {
    const defaultUrl =
        'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg';

    if (imageString == null || imageString.trim().isEmpty) {
      return const NetworkImage(defaultUrl);
    }

    if (imageString.startsWith('data:image')) {
      try {
        final base64Data = imageString.split(',').last;
        Uint8List bytes = base64Decode(base64Data);
        return MemoryImage(bytes);
      } catch (_) {
        return const NetworkImage(defaultUrl);
      }
    }

    if (imageString.startsWith('http')) {
      return NetworkImage(imageString);
    }

    return const NetworkImage(defaultUrl);
  }
}
