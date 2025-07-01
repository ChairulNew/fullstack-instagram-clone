import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fullstack_instagram_clone/screens/profile_screen.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Cari pengguna...',
            labelStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onFieldSubmitted: (value) {
            setState(() {
              searchText = value.trim().toLowerCase();
            });
          },
        ),
      ),
      body:
          searchText.isNotEmpty
              ? _buildUserSearchResult()
              : _buildExploreGrid(),
    );
  }

  Widget _buildUserSearchResult() {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('users')
              .where('username', isGreaterThanOrEqualTo: searchText)
              .where('username', isLessThanOrEqualTo: '$searchText\uf8ff')
              .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('Pengguna tidak ditemukan.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var user = docs[index].data() as Map<String, dynamic>;
            var userId = docs[index].id;

            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(uid: userId),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: _buildProfileImage(user['photoUrl']),
                ),
                title: Text(user['username'] ?? ''),
              ),
            );
          },
        );
      },
    );
  }

  /// Widget untuk grid Explore
  Widget _buildExploreGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: MasonryGridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildPostImage(data['postUrl']),
              );
            },
          ),
        );
      },
    );
  }

  /// Builder untuk foto profil
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

  /// Builder untuk post image
  Widget _buildPostImage(String? postUrl) {
    if (postUrl == null) return const Icon(Icons.broken_image);

    if (postUrl.startsWith('data:image')) {
      try {
        final base64Data = postUrl.split(',').last;
        Uint8List bytes = base64Decode(base64Data);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return const Icon(Icons.error);
      }
    }

    return Image.network(postUrl, fit: BoxFit.cover);
  }
}
