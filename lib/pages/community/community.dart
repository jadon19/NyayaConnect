import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post_model.dart';
import '../../services/community_service.dart';
import 'add_post_screen.dart';
import 'post_detail_screen.dart';
import '../../widgets/simple_gradient_header.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityService _communityService = CommunityService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserEmail;
  String? _currentUserProfilePic;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Get userId from users collection
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            _currentUserId = userData['userId'] as String? ?? user.uid;
            _currentUserName = userData['name'] as String? ?? 'User';
            _currentUserEmail = userData['email'] as String? ?? '';
            _currentUserProfilePic = userData['profilePicture'] as String?;
            _isLoadingUser = false;
          });
        } else {
          setState(() {
            _currentUserId = user.uid;
            _currentUserName = 'User';
            _currentUserEmail = user.email ?? '';
            _isLoadingUser = false;
          });
        }
      } else {
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUserId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: Text('Please login to view community')),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔵 NEW: Gradient header
          const SimpleGradientHeader(title: "Community"),

          // 🔵 Expanded keeps posts scrollable
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: _communityService.getAllPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share something!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {},
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return _PostCard(
                        post: posts[index],
                        currentUserId: _currentUserId!,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                post: posts[index],
                                currentUserId: _currentUserId!,
                                currentUserName: _currentUserName ?? 'User',
                                currentUserEmail: _currentUserEmail ?? '',
                                currentUserProfilePic: _currentUserProfilePic,
                              ),
                            ),
                          );
                        },
                        onLike: () {
                          _communityService.toggleLike(
                            posts[index].id,
                            _currentUserId!,
                          );
                        },
                        onDelete: posts[index].userId == _currentUserId
                            ? () => _showDeleteDialog(posts[index])
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostScreen(
                userId: _currentUserId!,
                userName: _currentUserName ?? 'User',
                userEmail: _currentUserEmail ?? '',
                userProfilePic: _currentUserProfilePic,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF004AAD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _communityService.deletePost(post.id);
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Post deleted')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  const _PostCard({
    required this.post,
    required this.currentUserId,
    required this.onTap,
    required this.onLike,
    this.onDelete,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = post.likes.contains(currentUserId);
    final isOwnPost = post.userId == currentUserId;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF87CEEB),
                  backgroundImage: post.userProfilePic != null
                      ? NetworkImage(post.userProfilePic!)
                      : null,
                  child: post.userProfilePic == null
                      ? Text(
                          post.userName.isNotEmpty
                              ? post.userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getTimeAgo(post.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isOwnPost)
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    color: Colors.grey[600],
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Post content
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                // Like button
                InkWell(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likes.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Comment button
                Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.commentCount}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
