import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final String profImage; // Pastikan ini tidak nullable
  final List likes;

  const Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
    "description": description,
    "uid": uid,
    "username": username,
    "postId": postId,
    "datePublished": datePublished,
    "postUrl": postUrl,
    "profImage": profImage, // Pastikan ini tidak null
    "likes": likes,
  };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      description: snapshot['description'] ?? '',
      uid: snapshot['uid'] ?? '',
      username: snapshot['username'] ?? 'Unknown User',
      postId: snapshot['postId'] ?? snap.id,
      datePublished:
          (snapshot['datePublished'] as Timestamp?)?.toDate() ?? DateTime.now(),
      postUrl: snapshot['postUrl'] ?? '',
      profImage:
          snapshot['profImage'] ??
          '', // Handle null dengan default empty string
      likes: List.from(snapshot['likes'] ?? []),
    );
  }

  /// Factory constructor dengan null safety yang lebih robust
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      description: (map['description'] as String?) ?? '',
      uid: (map['uid'] as String?) ?? '',
      username: (map['username'] as String?) ?? 'Unknown User',
      postId: (map['postId'] as String?) ?? '',
      datePublished:
          map['datePublished'] is Timestamp
              ? (map['datePublished'] as Timestamp).toDate()
              : DateTime.now(),
      postUrl: (map['postUrl'] as String?) ?? '',
      profImage: (map['profImage'] as String?) ?? '', // Default empty string
      likes: List.from(map['likes'] ?? []),
    );
  }

  /// Method untuk membuat copy dengan perubahan
  Post copyWith({
    String? description,
    String? uid,
    String? username,
    String? postId,
    DateTime? datePublished,
    String? postUrl,
    String? profImage,
    List? likes,
  }) {
    return Post(
      description: description ?? this.description,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      postId: postId ?? this.postId,
      datePublished: datePublished ?? this.datePublished,
      postUrl: postUrl ?? this.postUrl,
      profImage: profImage ?? this.profImage,
      likes: likes ?? this.likes,
    );
  }

  @override
  String toString() {
    return 'Post(description: $description, uid: $uid, username: $username, postId: $postId, datePublished: $datePublished, postUrl: ${postUrl.length > 50 ? postUrl.substring(0, 50) + "..." : postUrl}, profImage: ${profImage.length > 50 ? profImage.substring(0, 50) + "..." : profImage}, likes: $likes)';
  }
}
