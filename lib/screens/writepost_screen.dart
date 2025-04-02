import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WritePostScreen extends StatefulWidget {
  final bool isEditing;
  final bool isReporting;
  final String? postId;
  final String? initialTitle;
  final String? initialContent;
  final List<String>? initialImageUrls;
  final String? initialType;

  WritePostScreen({
    this.isEditing = false,
    this.isReporting = false,
    this.postId,
    this.initialTitle,
    this.initialContent,
    this.initialImageUrls,
    this.initialType,
  });

  @override
  _WritePostScreenState createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<String> _imageUrls = [];
  bool _isUploading = false;
  String _selectedType = 'normal';

  final List<String> _postTypes = ['normal', 'report', 'recycle'];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
    _imageUrls = List<String>.from(widget.initialImageUrls ?? []);
    _selectedType = widget.initialType ?? (widget.isReporting ? 'report' : 'normal');
  }

  Future<void> _pickAndUploadImages(ImageSource source) async {
    List<XFile>? images;

    if (source == ImageSource.gallery) {
      images = await _picker.pickMultiImage();
    } else {
      final singleImage = await _picker.pickImage(source: source);
      if (singleImage != null) images = [singleImage];
    }

    if (images == null || images.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      for (var image in images) {
        File file = File(image.path);
        String fileName = "${DateTime.now().millisecondsSinceEpoch}_${image.name}";

        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('uploads/$fileName')
            .putFile(file);

        String downloadUrl = await snapshot.ref.getDownloadURL();
        _imageUrls.add(downloadUrl);
      }
    } catch (e) {
      print("이미지 업로드 실패: $e");
    }

    setState(() => _isUploading = false);
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text("카메라로 촬영"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImages(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.green),
              title: Text("갤러리에서 선택"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImages(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (title.isEmpty || content.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          title: Text('입력 확인', style: TextStyle(color: Colors.white)),
          content: Text('제목과 내용을 모두 입력해 주세요.', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              child: Text('확인', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final postData = {
      'title': title,
      'content': content,
      'imageUrls': _imageUrls,
      'authorEmail': currentUser?.email ?? '익명',
      'authorName': currentUser?.displayName ?? '익명',
      'timestamp': FieldValue.serverTimestamp(),
      'type': _selectedType,
    };

    if (widget.isEditing && widget.postId != null) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update(postData);
    } else {
      final targetCollection = widget.isReporting ? 'reports' : 'posts';
      await FirebaseFirestore.instance
          .collection(targetCollection)
          .add(postData);
    }

    _titleController.clear();
    _contentController.clear();
    setState(() => _imageUrls = []);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 11.0, right: 15.0, top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('assets/Close.png', width: 40, height: 40),
                  ),
                  GestureDetector(
                    onTap: _showImageSourceActionSheet,
                    child: Image.asset('assets/Camera.png', width: 40, height: 40),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "제목",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(color: Colors.white),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: _contentController,
                              maxLines: null,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "내용을 입력하세요.",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _submitPost(),
                            ),
                            if (_isUploading)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            if (_imageUrls.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _imageUrls.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 10.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            _imageUrls[index],
                                            width: 150,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isReporting ? Colors.red : Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _submitPost,
                        child: Text(
                          widget.isReporting ? "신고하기" : widget.isEditing ? "수정 완료" : "등록",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
