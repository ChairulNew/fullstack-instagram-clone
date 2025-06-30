import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
          searchText.isEmpty
              ? const Center(child: Text('Masukkan username untuk mencari.'))
              : FutureBuilder(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .where('username', isGreaterThanOrEqualTo: searchText)
                        .where(
                          'username',
                          isLessThanOrEqualTo: '$searchText\uf8ff',
                        )
                        .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Pengguna tidak ditemukan.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var user = docs[index].data();
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: _buildProfileImage(user['photoUrl']),
                        ),
                        title: Text(user['username']),
                        subtitle: Text(user['email'] ?? ''),
                      );
                    },
                  );
                },
              ),
    );
  }

  /// Helper untuk menampilkan foto profil (base64, URL, atau fallback default)
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
