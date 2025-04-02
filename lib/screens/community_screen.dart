import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'postdetail_screen.dart';
import 'writepost_screen.dart';

class CommunityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Center(
            child: Column(
              children: [
                Image.asset('assets/logo.png', width: 95, height: 74),
                SizedBox(height: 10),
                Text(
                  "고민을 나누고 해결책을 찾아보세요.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final posts = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['type'] != 'report';
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final data = post.data() as Map<String, dynamic>;

                    final postId = post.id;
                    final title = data['title'] ?? '제목 없음';
                    final authorName = data['authorName'] ?? '익명';
                    final imageUrls = List<String>.from(data['imageUrls'] ?? []);
                    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
                    final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(postId)
                          .collection('comments')
                          .snapshots(),
                      builder: (context, commentSnapshot) {
                        final commentCount = commentSnapshot.data?.docs.length ?? 0;
                        final likes = data['likes'] ?? 0;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PostDetailScreen(
                                      postId: postId,
                                      title: title,
                                      authorEmail: data['authorEmail'] ?? '익명',
                                      content: data['content'] ?? '',
                                      imageUrls: imageUrls,
                                      timestamp: timestamp,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: imageUrl != null
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          width: 90,
                                          height: 100,
                                        ),
                                      )
                                          : Image.asset('assets/Image.png', width: 30, height: 30),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              authorName,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              '댓글 $commentCount개 · 좋아요 $likes개',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Divider(color: Colors.white38, thickness: 1),
                            ),
                          ],
                        );
                      },
                    );
                  },
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
            MaterialPageRoute(builder: (context) => WritePostScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.edit, color: Colors.white),
        shape: CircleBorder(),
      ),
    );
  }
}
