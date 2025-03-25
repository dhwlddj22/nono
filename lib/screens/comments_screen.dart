import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'writepost_screen.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String postTitle;

  CommentsScreen({required this.postId, required this.postTitle});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  void _addComment() async {
    if (user == null || _commentController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'userEmail': user!.email,
      'text': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({'commentCount': FieldValue.increment(1)});

    _commentController.clear();
  }

  void _editComment(String commentId, String currentText) async {
    final controller = TextEditingController(text: currentText);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text("댓글 수정", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: null,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "내용 수정",
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .doc(commentId)
                    .update({'text': newText});
              }
              Navigator.pop(context);
            },
            child: Text("수정", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _deleteComment(String commentId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text("댓글 삭제", style: TextStyle(color: Colors.white)),
        content: Text("댓글을 삭제하시겠습니까?", style: TextStyle(color: Colors.white70)),
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
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({'commentCount': FieldValue.increment(-1)});
    }
  }

  void _reportComment(String userEmail, String text) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WritePostScreen(
          isReporting: true,
          postId: widget.postId,
          initialTitle: '[댓글 신고] $userEmail',
          initialContent: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: BackButton(color: Colors.white),
        title: Text(widget.postTitle, style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final comments = snapshot.data!.docs;

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.white12),
                  itemBuilder: (context, index) {
                    final doc = comments[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final commentId = doc.id;
                    final userEmail = data['userEmail'] ?? '익명';
                    final text = data['text'] ?? '';
                    final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final isOwner = userEmail == user?.email;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue.shade200,
                          child: Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5 ),
                                        children: [
                                          TextSpan(
                                            text: '$userEmail\n',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: text,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    color: Colors.white,
                                    onSelected: (value) {
                                      if (value == 'edit') _editComment(commentId, text);
                                      else if (value == 'delete') _deleteComment(commentId);
                                      else if (value == 'report') _reportComment(userEmail, text);
                                    },
                                    itemBuilder: (_) {
                                      if (isOwner) {
                                        return [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Text("수정", style: TextStyle(color: Colors.black)),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text("삭제", style: TextStyle(color: Colors.black)),
                                          ),
                                        ];
                                      } else {
                                        return [
                                          PopupMenuItem(
                                            value: 'report',
                                            child: Text("신고", style: TextStyle(color: Colors.black)),
                                          ),
                                        ];
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${timestamp.year}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.day.toString().padLeft(2, '0')} '
                                    '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "댓글을 남겨보세요",
                      hintStyle: TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward, color: Colors.black),
                    onPressed: _addComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
