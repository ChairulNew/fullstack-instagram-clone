import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullstack_instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:fullstack_instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:fullstack_instagram_clone/responsive/web_screen_layout.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';
import 'package:fullstack_instagram_clone/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: SvgPicture.asset(
          "assets/instagram-logo.svg",
          color: primaryColor,
          height: 32,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.messenger_outline)),
        ],
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('posts')
                .orderBy(
                  'datePublished',
                  descending: true,
                ) // Urutkan berdasarkan tanggal
                .snapshots(),
        builder: (
          context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 50, color: Colors.red),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add, size: 50, color: Colors.grey),
                  Text('No posts available'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              Map<String, dynamic> postData =
                  doc.data() as Map<String, dynamic>;
              print('=== POST $index ===');
              print('Document ID: ${doc.id}');
              print('Raw data: $postData');
              print('profilImage field: ${postData['profilImage']}');
              print('profilImage type: ${postData['profilImage'].runtimeType}');
              print('==================');

              Map<String, dynamic> enrichedData = _enrichPostData(
                postData,
                doc.id,
              );

              return Container(
                margin: EdgeInsets.only(bottom: 8),
                child: PostCard(snap: enrichedData),
              );
            },
          );
        },
      ),
    );
  }

  Map<String, dynamic> _enrichPostData(
    Map<String, dynamic> originalData,
    String docId,
  ) {
    Map<String, dynamic> enrichedData = Map<String, dynamic>.from(originalData);

    if (enrichedData['profilImage'] == null ||
        enrichedData['profilImage'].toString().trim().isEmpty) {
      print('profilImage is null/empty for doc: $docId');

      // Coba ambil profilImage dari user collection berdasarkan uid
      _fetchUserProfileImage(enrichedData['uid']).then((userProfilImage) {
        if (userProfilImage != null) {
          print('Found profilImage from users collection: $userProfilImage');
          // Update akan terjadi pada build selanjutnya
        }
      });

      // Set default untuk sementara
      enrichedData['profilImage'] = null;
    }

    // Ensure required fields exist
    enrichedData['username'] = enrichedData['username'] ?? 'Unknown User';
    enrichedData['description'] = enrichedData['description'] ?? '';
    enrichedData['datePublished'] =
        enrichedData['datePublished'] ?? Timestamp.now();
    enrichedData['postUrl'] = enrichedData['postUrl'] ?? '';
    enrichedData['likes'] = enrichedData['likes'] ?? [];
    enrichedData['uid'] = enrichedData['uid'] ?? '';
    enrichedData['postId'] = enrichedData['postId'] ?? docId;

    return enrichedData;
  }

  /// Fungsi untuk mengambil profilImage dari collection users
  Future<String?> _fetchUserProfileImage(String? uid) async {
    if (uid == null || uid.isEmpty) return null;

    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['photoUrl'] as String?;
      }
    } catch (e) {
      print('Error fetching user profile image: $e');
    }

    return null;
  }
}
