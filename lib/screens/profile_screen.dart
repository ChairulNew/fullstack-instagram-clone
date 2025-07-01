import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fullstack_instagram_clone/resources/auth_methods.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';
import 'package:fullstack_instagram_clone/utils/utils.dart';
import 'package:fullstack_instagram_clone/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentAuthUser = authSnapshot.data!;

        return StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('User not found')),
              );
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;

            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .orderBy('datePublished', descending: true)
                      .snapshots(),
              builder: (context, postsSnapshot) {
                final postLen =
                    postsSnapshot.hasData ? postsSnapshot.data!.docs.length : 0;
                final followers = (userData['followers'] as List? ?? []).length;
                final following = (userData['following'] as List? ?? []).length;
                final isFollowing = (userData['followers'] as List? ?? [])
                    .contains(currentAuthUser.uid);

                return Scaffold(
                  backgroundColor: mobileBackgroundColor,
                  appBar: AppBar(
                    backgroundColor: mobileBackgroundColor,
                    title: Text(userData['username'] ?? 'Username'),
                    centerTitle: false,
                    actions: [
                      if (currentAuthUser.uid == widget.uid)
                        IconButton(
                          onPressed: () async {
                            await AuthMethods().signOut();
                            if (!mounted) return;
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                          },
                          icon: const Icon(Icons.logout),
                          tooltip: 'Sign Out',
                        ),
                    ],
                  ),
                  body: RefreshIndicator(
                    onRefresh: () async {
                      // Force refresh dengan rebuild
                      setState(() {});
                    },
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: _buildProfileImage(
                                      userData['photoUrl'],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildStatColumn(postLen, 'Posts'),
                                        buildStatColumn(followers, 'Followers'),
                                        buildStatColumn(following, 'Following'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  userData['name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(userData['bio'] ?? ''),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        currentAuthUser.uid == widget.uid
                                            ? FollowButton(
                                              text: 'Edit Profile',
                                              backgroundColor:
                                                  mobileBackgroundColor,
                                              textColor: primaryColor,
                                              borderColor: Colors.grey,
                                              function: () {},
                                            )
                                            : isFollowing
                                            ? FollowButton(
                                              text: 'Unfollow',
                                              backgroundColor: Colors.white,
                                              textColor: Colors.black,
                                              borderColor: Colors.grey,
                                              function: () async {
                                                await _unfollowUser(
                                                  currentAuthUser.uid,
                                                );
                                              },
                                            )
                                            : FollowButton(
                                              text: 'Follow',
                                              backgroundColor: Colors.blue,
                                              textColor: Colors.white,
                                              borderColor: Colors.blue,
                                              function: () async {
                                                await _followUser(
                                                  currentAuthUser.uid,
                                                );
                                              },
                                            ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 8),
                        if (!postsSnapshot.hasData)
                          const Center(child: CircularProgressIndicator())
                        else if (postsSnapshot.data!.docs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Center(child: Text('Belum ada postingan.')),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: MasonryGridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              itemCount: postsSnapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final data =
                                    postsSnapshot.data!.docs[index].data()
                                        as Map<String, dynamic>;
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildPostImage(data['postUrl']),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _followUser(String currentUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
            'following': FieldValue.arrayUnion([widget.uid]),
          });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
            'followers': FieldValue.arrayUnion([currentUserId]),
          });
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _unfollowUser(String currentUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
            'following': FieldValue.arrayRemove([widget.uid]),
          });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
            'followers': FieldValue.arrayRemove([currentUserId]),
          });
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  Column buildStatColumn(int number, String label) {
    return Column(
      children: [
        Text(
          number.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
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
