import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'comments_screen.dart';
import 'writepost_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String title;
  final String authorEmail;
  final String content;
  final List<String> imageUrls;
  final DateTime timestamp;

  PostDetailScreen({
    required this.postId,
    required this.title,
    required this.authorEmail,
    required this.content,
    required this.imageUrls,
    required this.timestamp,
  });

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final user = FirebaseAuth.instance.currentUser;

  void _toggleLike(bool isLiked, int likes, List<dynamic> likedBy) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

    final updatedLikes = isLiked ? likes - 1 : likes + 1;
    if (isLiked) {
      likedBy.remove(user?.email);
    } else {
      likedBy.add(user?.email);
    }

    await postRef.update({
      'likes': updatedLikes,
      'likedBy': likedBy,
    });
  }

  void _showDeleteConfirmDialog() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text("게시글 삭제", style: TextStyle(color: Colors.white)),
        content: Text("정말 이 게시글을 삭제하시겠습니까?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: Text("취소", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("삭제", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).delete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 35), // ← 여기서 size 조절
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WritePostScreen(
                      isReporting: true,
                      postId: widget.postId,
                      initialTitle: '[게시글 신고] ${widget.title}',
                      initialContent: widget.content,
                    ),
                  ),
                );
              } else if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WritePostScreen(
                      isEditing: true,
                      postId: widget.postId,
                      initialTitle: widget.title,
                      initialContent: widget.content,
                      initialImageUrls: widget.imageUrls,
                    ),
                  ),
                );
              } else if (value == 'delete') {
                _showDeleteConfirmDialog();
              }
            },
            itemBuilder: (_) {
              final isAuthor = user?.email == widget.authorEmail;
              return [
                if (!isAuthor) PopupMenuItem(value: 'report', child: Text("신고")),
                if (isAuthor) PopupMenuItem(value: 'edit', child: Text("수정")),
                if (isAuthor) PopupMenuItem(value: 'delete', child: Text("삭제")),
              ];
            },
            icon: Icon(Icons.more_vert, color: Colors.white,size: 35,),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).snapshots(),
        builder: (context, postSnapshot) {
          if (!postSnapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = postSnapshot.data!.data() as Map<String, dynamic>;
          final likes = data['likes'] ?? 0;
          final commentCount = data['commentCount'] ?? 0;
          final likedBy = List<String>.from(data['likedBy'] ?? []);
          final isLiked = likedBy.contains(user?.email);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[400],
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.authorEmail,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(
                          "${widget.timestamp.year}.${widget.timestamp.month.toString().padLeft(2, '0')}.${widget.timestamp.day.toString().padLeft(2, '0')} "
                              "${widget.timestamp.hour.toString().padLeft(2, '0')}:${widget.timestamp.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 13),
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Divider(color: Colors.white),
                if (widget.imageUrls.isNotEmpty)
                  ...widget.imageUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                  )),
                SizedBox(height: 12),
                Text(widget.content, style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 30),
                Divider(color: Colors.white30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => _toggleLike(isLiked, likes, likedBy),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text('$likes', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommentsScreen(
                              postId: widget.postId,
                              postTitle: widget.title,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline, color: Colors.white),
                          SizedBox(width: 4),
                          Text('$commentCount', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
