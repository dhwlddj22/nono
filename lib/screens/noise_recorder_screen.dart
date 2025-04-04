import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'chat_history_screen.dart';
import 'my_page_screen.dart';
import 'noise_analysis_screen.dart';

class NoiseRecordScreen extends StatefulWidget {
  @override
  State<NoiseRecordScreen> createState() => _NoiseRecordScreenState();
}

class _NoiseRecordScreenState extends State<NoiseRecordScreen> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    await Permission.microphone.request();
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    _filePath = '${dir.path}/noise_recording.aac';

    await _recorder!.startRecorder(toFile: _filePath);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    if (_filePath != null) {
      final file = File(_filePath!);
      final fileName = _filePath!.split('/').last;
      final ref = FirebaseStorage.instance
          .ref('uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      await ref.putFile(file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('녹음이 저장되었습니다')),
      );
    }
  }

  void _cancelRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _filePath = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('녹음이 취소되었습니다')),
    );
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('NO!SE GUARD'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chat),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ChatHistoryScreen()));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MyPageScreen()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 80),
          Text(
            '스마트한 층간소음 해결, 노이즈가드',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            '아래 아이콘을 눌러 소음을 분석해보세요',
            style: TextStyle(color: Colors.green),
          ),
          SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _circleIcon(Icons.chat_bubble_outline, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => NoiseAnalysisChatScreen()));
              }),
              _circleIcon(
                _isRecording ? Icons.stop : Icons.multitrack_audio,
                    () {
                  _isRecording ? _stopRecording() : _startRecording();
                },
              ),
              _circleIcon(Icons.close, () {
                if (_isRecording) _cancelRecording();
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Colors.green,
        radius: 30,
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }
}
