import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all posts ordered by creation time (newest first)
  Stream<List<Post>> getAllPosts() {
    return _firestore
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromFirestore(doc))
            .toList());
  }

  // Get posts by a specific user
  Stream<List<Post>> getUserPosts(String userId) {
    return _firestore
        .collection('community_posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromFirestore(doc))
            .toList());
  }

  // Create a new post
  Future<String> createPost({
    required String userId,
    required String userName,
    required String userEmail,
    String? userProfilePic,
    required String content,
  }) async {
    try {
      final postRef = await _firestore.collection('community_posts').add({
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'userProfilePic': userProfilePic,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
        'commentCount': 0,
      });
      return postRef.id;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Like/Unlike a post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('community_posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      final postData = postDoc.data()!;
      final likes = List<String>.from(postData['likes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await postRef.update({'likes': likes});
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Get comments for a post
  Stream<List<Comment>> getPostComments(String postId) {
    return _firestore
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromFirestore(doc))
            .toList());
  }

  // Add a comment to a post
  Future<String> addComment({
    required String postId,
    required String userId,
    required String userName,
    String? userProfilePic,
    required String content,
  }) async {
    try {
      // Add comment to subcollection
      final commentRef = await _firestore
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .add({
        'postId': postId,
        'userId': userId,
        'userName': userName,
        'userProfilePic': userProfilePic,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update comment count in post
      final postRef = _firestore.collection('community_posts').doc(postId);
      await postRef.update({
        'commentCount': FieldValue.increment(1),
      });

      return commentRef.id;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Delete a post (only by the post owner)
  Future<void> deletePost(String postId) async {
    try {
      // Delete all comments first
      final commentsSnapshot = await _firestore
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .get();

      final batch = _firestore.batch();
      for (var doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete the post
      await _firestore.collection('community_posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Get user data from users collection
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }
}

