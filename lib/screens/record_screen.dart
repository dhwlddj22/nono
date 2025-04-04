import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'NoiseAnalysisChatScreenWithNav.dart';
import 'chat_history_screen.dart';
import 'main_screen.dart';
import 'noise_analysis_screen.dart';
import 'my_page_screen.dart';

class RecordScreen extends StatefulWidget {
  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool _isRecording = false;
  late FlutterSoundRecorder _recorder;
  late NoiseMeter _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  List<double> _decibelValues = [];
  String? _recordFilePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _noiseMeter = NoiseMeter();
    _init();
  }

  Future<void> _init() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    _recordFilePath = '${dir.path}/recorded_noise.aac';

    await _recorder.startRecorder(toFile: _recordFilePath);
    _noiseSubscription = _noiseMeter.noise.listen((event) {
      setState(() {
        _decibelValues.add(event.meanDecibel);
      });
    });

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    await _noiseSubscription?.cancel();
    setState(() {
      _isRecording = false;
    });

    if (_recordFilePath != null) {
      final file = File(_recordFilePath!);
      final fileName = _recordFilePath!.split('/').last;

      final ref = FirebaseStorage.instance
          .ref('uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      await ref.putFile(file);

      final averageDb = _calculateAverage();

      await FirebaseFirestore.instance.collection('decibel_analysis').add({
        'average_db': averageDb.toStringAsFixed(2),
        'timestamp': Timestamp.now(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NoiseAnalysisChatScreenWithNav(
            initialInput: "평균 소음 수준은 ${averageDb.toStringAsFixed(2)} dB 입니다. 분석해줘.",
          ),
        ),
      );



      _decibelValues.clear();
    }
  }

  Future<void> _cancelRecording() async {
    await _recorder.stopRecorder();
    await _noiseSubscription?.cancel();
    setState(() {
      _isRecording = false;
      _recordFilePath = null;
      _decibelValues.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('녹음이 취소되었습니다.')),
    );
  }

  double _calculateAverage() {
    if (_decibelValues.isEmpty) return 0;
    return _decibelValues.reduce((a, b) => a + b) / _decibelValues.length;
  }

  Widget _buildDecibelChart() {
    final points = _decibelValues.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            color: Colors.green, // ✅ 단일 색상 사용
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.3),
            ),
          )

        ],
      ),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _noiseSubscription?.cancel();
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
          SizedBox(height: 20),
          Text(
            '실시간 데시벨 측정',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(height: 180, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDecibelChart(),
          )),
          SizedBox(height: 10),
          Text(
            _decibelValues.isNotEmpty
                ? "평균 데시벨: ${_calculateAverage().toStringAsFixed(2)} dB"
                : "측정값 없음",
            style: TextStyle(color: Colors.green, fontSize: 18),
          ),
          SizedBox(height: 40),
          Text(
            '스마트한 층간소음 해결, 노이즈가드',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            '아래 아이콘을 눌러 소음을 분석해보세요',
            style: TextStyle(color: Colors.green),
          ),
          SizedBox(height: 50),
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
