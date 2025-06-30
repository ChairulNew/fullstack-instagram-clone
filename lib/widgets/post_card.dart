import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fullstack_instagram_clone/providers/user_provider.dart';
import 'package:fullstack_instagram_clone/resources/firestore_method.dart';
import 'package:fullstack_instagram_clone/screens/comments_screen.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';
import 'package:fullstack_instagram_clone/widgets/like_animation.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String _formatDate(dynamic timestamp) {
    if (timestamp == null || timestamp is! Timestamp) {
      return 'Unknown';
    }
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  bool isLikeAnimiting = false;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).getUser;

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
                  backgroundImage: _buildProfilImage(
                    widget.snap['profilImage'],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.snap['username'] ?? "Username",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                if (user != null && widget.snap['uid'] == user.uid)
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Konfirmasi"),
                              content: const Text(
                                "Yakin ingin menghapus postingan ini?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await FirestoreMethods().deletePost(
                                      widget.snap['postId'],
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    icon: const Icon(Icons.more_vert_outlined),
                  )
                else
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => const AlertDialog(
                              title: Text("Akses Ditolak"),
                              content: Text(
                                "Kamu tidak bisa menghapus postingan orang lain.",
                              ),
                            ),
                      );
                    },
                    icon: const Icon(Icons.more_vert_outlined),
                  ),
              ],
            ),
          ),

          GestureDetector(
            onDoubleTap: () async {
              setState(() {
                isLikeAnimiting = true;
              });
              await FirestoreMethods().likePost(
                widget.snap['postId'],
                user!.uid,
                widget.snap['likes'],
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _buildPostImage(widget.snap['postUrl']),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimiting ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimiting,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimiting = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user?.uid ?? ''),
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    if (user != null) {
                      await FirestoreMethods().likePost(
                        widget.snap['postId'],
                        user.uid,
                        widget.snap['likes'],
                      );
                    }
                  },
                  icon: Icon(
                    Icons.favorite,
                    color:
                        widget.snap['likes'].contains(user?.uid ?? '')
                            ? Colors.redAccent
                            : Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CommentsScreen(postId: widget.snap['postId']),
                      ),
                    ),
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

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w800),
                  child: Text('${widget.snap['likes'].length} likes'),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'] ?? "username",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              " ${widget.snap['description'] ?? 'No caption'}",
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.snap['postId'])
                          .collection('comments')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const SizedBox.shrink();
                    }
                    int commentCount = snapshot.data!.docs.length;
                    return InkWell(
                      onTap:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => CommentsScreen(
                                    postId: widget.snap['postId'],
                                  ),
                            ),
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Lihat semua $commentCount komen',
                          style: const TextStyle(
                            fontSize: 12,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  _formatDate(widget.snap['datePublished']),
                  style: const TextStyle(fontSize: 12, color: secondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _buildProfilImage(String? imageString) {
    const defaultUrl =
        'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg';
    if (imageString == null || imageString.trim().isEmpty)
      return const NetworkImage(defaultUrl);
    if (imageString.startsWith('data:image')) {
      try {
        final base64Data = imageString.split(',').last;
        Uint8List bytes = base64Decode(base64Data);
        return MemoryImage(bytes);
      } catch (_) {
        return const NetworkImage(defaultUrl);
      }
    }
    if (imageString.startsWith('http')) return NetworkImage(imageString);
    return const NetworkImage(defaultUrl);
  }

  Widget _buildPostImage(String? postUrl) {
    if (postUrl == null)
      return const Center(child: Icon(Icons.image_not_supported));
    if (postUrl.startsWith('data:image')) {
      try {
        final base64Data = postUrl.split(',').last;
        Uint8List bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          width: double.infinity,
        );
      } catch (_) {
        return const Center(child: Icon(Icons.broken_image));
      }
    }
    if (postUrl.startsWith('http')) {
      return Image.network(
        postUrl,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        width: double.infinity,
      );
    }
    return const Center(child: Icon(Icons.image));
  }
}
