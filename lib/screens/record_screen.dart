import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'NoiseAnalysisChatScreenWithNav.dart';
import 'chat_history_screen.dart';
import 'noise_analysis_screen.dart';
import 'my_page_screen.dart';
import 'package:intl/intl.dart';
import 'noise_prompt_builder.dart';
import 'openai_service.dart';

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
  Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;

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

  void _showLoadingDialog({
    required bool isSuccess,
    double width = 150,
    double height = 150,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: width,
            height: height,
            child: Lottie.asset(
              isSuccess ? 'assets/success.json' : 'assets/loading.json',
              repeat: !isSuccess,
            ),
          ),
        );
      },
    );
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);
    _recordFilePath = '${dir.path}/$formattedTime.aac';


    await _recorder.startRecorder(toFile: _recordFilePath);
    _stopwatch.reset();
    _stopwatch.start();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {});
    });

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
    _showLoadingDialog(isSuccess: false, width: 120, height: 120);

    await _recorder.stopRecorder();
    await _noiseSubscription?.cancel();

    final file = File(_recordFilePath!);
    final fileName = _recordFilePath!.split('/').last;

    final ref = FirebaseStorage.instance
        .ref('uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    await ref.putFile(file);


      // 🔼 Firebase Storage 업로드
      final ref = FirebaseStorage.instance.ref('uploads/$fileName');
      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();

      // 🔽 Firestore 파일 메시지 저장
      await FirebaseFirestore.instance.collection('chat_history').add({
        'text': fileName,
        'type': 'audio',
        'url': downloadUrl,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': Timestamp.now(),
      });

      // 📊 평균 데시벨 계산
      final averageDb = _calculateAverage();

      // 🔽 분석 요청 메시지 저장 (MessageType.user)
      final prompt =
          "${DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(DateTime.now())}에 측정된 평균 소음은 ${averageDb.toStringAsFixed(2)} dB입니다. 분석해줘.";
      await FirebaseFirestore.instance.collection('chat_history').add({
        'text': prompt,
        'type': 'user',
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': Timestamp.now(),
      });

      // 🤖 GPT 분석 응답
      final reply = await OpenAIService.analyzeNoise(prompt);
      await FirebaseFirestore.instance.collection('chat_history').add({
        'text': reply ?? "AI 응답 실패",
        'type': 'ai',
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': Timestamp.now(),
      });

      _decibelValues.clear();

      // ✅ 채팅 화면으로 이동 (자동 메시지 포함)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NoiseAnalysisChatScreenWithNav(initialInput: prompt, // ✅ 꼭 전달되어야 함
          ),
        ),
      );
    }
  }




    final averageDb = _calculateAverage();
    final peakDb = _decibelValues.isNotEmpty
        ? _decibelValues.reduce((a, b) => a > b ? a : b)
        : averageDb;

    await FirebaseFirestore.instance.collection('decibel_analysis').add({
      'average_db': averageDb.toStringAsFixed(2),
      'peak_db': peakDb.toStringAsFixed(2),
      'timestamp': Timestamp.now(),
    });

    final prompt = NoisePromptBuilder.build(
      averageDb: averageDb,
      peakDb: peakDb,
    );

    Navigator.pop(context); // Close loading
    _showLoadingDialog(isSuccess: true, width: 200, height: 200); // Success

    await Future.delayed(Duration(seconds: 3));
    Navigator.pop(context); // Close success

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NoiseAnalysisChatScreenWithNav(initialInput: prompt),
      ),
    );

    setState(() {
      _isRecording = false;
      _decibelValues.clear();
    });
  }

  Future<void> _cancelRecording() async {
    await _recorder.stopRecorder();
    await _noiseSubscription?.cancel();
    _stopwatch.stop();
    _timer.cancel();

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
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            color: Colors.green,
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

  String _formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _noiseSubscription?.cancel();
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('NO!SE GUARD'),
        titleTextStyle: TextStyle(
          color: const Color(0xFF58B721),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chat, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatHistoryScreen())),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyPageScreen())),
          ),
        ],
      ),
      body: _isRecording ? _buildRecordingView() : _buildIdleView(),
    );
  }

  Widget _buildIdleView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Image.asset('assets/logo.png', width: 105, height: 104),
          const SizedBox(height: 10),
          const Text("스마트한 층간소음 해결", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
          const Text("NO!SE GUARD", style: TextStyle(fontSize: 30, color: Color(0xFF57CC1C), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          const Text("아래의 녹음 버튼을 눌러 소음을 분석해보세요", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF57CC1C), fontWeight: FontWeight.bold)),
          const SizedBox(height: 100),
          GestureDetector(
            onTap: _startRecording,
            child: Image.asset('assets/record.png', width: 120, height: 120),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text("새로운 녹음 제목", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(
          "${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("평균 데시벨 ", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text("${_calculateAverage().toStringAsFixed(2)} dB", style: const TextStyle(color: Color(0xFF57CC1C), fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(height: 160, child: _buildDecibelChart()),
        ),
        const SizedBox(height: 16),
        Text(_formatDuration(_stopwatch.elapsed), style: const TextStyle(color: Colors.white, fontSize: 37, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoiseAnalysisChatScreen())),
              child: SvgPicture.asset('assets/chat.svg', width: 38, height: 38),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: _stopRecording,
              child: SvgPicture.asset('assets/recording.svg', width: 140, height: 140),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: _cancelRecording,
              child: SvgPicture.asset('assets/trash.svg', width: 38, height: 38),
            ),
          ],
        ),
      ],
    );
  }
}
