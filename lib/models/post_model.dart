import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userProfilePic;
  final String content;
  final DateTime createdAt;
  final List<String> likes;
  final int commentCount;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userProfilePic,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.commentCount,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userEmail: data['userEmail'] ?? '',
      userProfilePic: data['userProfilePic'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userProfilePic': userProfilePic,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'commentCount': commentCount,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userProfilePic,
    String? content,
    DateTime? createdAt,
    List<String>? likes,
    int? commentCount,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfilePic;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfilePic,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userProfilePic: data['userProfilePic'],
      content: data['content'] ?? '',
      createdAt: data['createdAt'] is Timestamp
    ? (data['createdAt'] as Timestamp).toDate()
    : DateTime.tryParse(data['createdAt'] ?? "") ?? DateTime.now(),

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

