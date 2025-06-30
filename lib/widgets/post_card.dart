import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';

class PostCard extends StatelessWidget {
  final snap;
  String _formatDate(dynamic timestamp) {
    if (timestamp == null || timestamp is! Timestamp) {
      return 'Unknown';
    }

    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: _buildProfilImage(snap['profilImage']),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snap['username'] ?? "Username",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => Dialog(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shrinkWrap: true,
                              children:
                                  ["Hapus"].map((e) {
                                    return InkWell(
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        child: Text(e),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                    );
                  },
                  icon: const Icon(Icons.more_vert_outlined),
                ),
              ],
            ),
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: _buildPostImage(snap['postUrl']),
          ),

          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite, color: Colors.redAccent),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.comment_outlined),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border),
              ),
            ],
          ),

          // Caption and metadata
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w800),
                  child: Text('1.211 likes'),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: snap['username'] ?? "username",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: " ${snap['description'] ?? 'No caption'}",
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text(
                      "lihat semua 200 komen",
                      style: TextStyle(fontSize: 12, color: secondaryColor),
                    ),
                  ),
                ),
                Text(
                  _formatDate(snap['datePublished']),
                  style: const TextStyle(fontSize: 12, color: secondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk gambar profil (base64, URL, atau fallback default)
  ImageProvider _buildProfilImage(String? imageString) {
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

  /// Helper untuk gambar postingan (base64 atau URL)
  Widget _buildPostImage(String? postUrl) {
    if (postUrl == null) {
      return const Center(child: Icon(Icons.image_not_supported));
    }

    if (postUrl.startsWith('data:image')) {
      try {
        final base64Data = postUrl.split(',').last;
        Uint8List bytes = base64Decode(base64Data);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return const Center(child: Icon(Icons.broken_image));
      }
    }

    if (postUrl.startsWith('http')) {
      return Image.network(postUrl, fit: BoxFit.cover);
    }

    return const Center(child: Icon(Icons.image));
  }
}
