import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:nono/screens/noise_main/chat_history_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
// import 'NoiseAnalysisChatScreenWithNav.dart';
import 'package:intl/intl.dart';
import 'chat_detail_screen.dart';
import 'chat_history_screen.dart';
import 'message.dart';
import 'my_page_screen.dart';
// import 'noise_analysis_screen.dart';
import 'noise_prompt_builder.dart';
import 'openai_service.dart';

enum ViewMode { idle, history, detail }

ViewMode viewMode = ViewMode.idle;

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  RecordScreenState createState() => RecordScreenState();
}

class RecordScreenState extends State<RecordScreen> {
  bool _isRecording = false;
  late FlutterSoundRecorder _recorder;
  late NoiseMeter _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  final List<double> _decibelValues = [];
  String? _recordFilePath;
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String? selectedFormattedDate; // 채팅 기록 날짜 (상태변수)
  String? pendingInput; // chat_detail_screen에 넘기는 데이터

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _noiseMeter = NoiseMeter();
    _init();
    fetchChatHistory();
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
              isSuccess ? 'assets/noise_main/success.json' : 'assets/noise_main/loading.json',
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

    _stopwatch.stop();
    if (_timer.isActive) _timer.cancel();


    _showLoadingDialog(isSuccess: false, width: 120, height: 120);

    await _recorder.stopRecorder();
    await _noiseSubscription?.cancel();

    final file = File(_recordFilePath!);
    final fileName = _recordFilePath!.split('/').last;

    // 🔼 Firebase Storage 업로드
    final ref = FirebaseStorage.instance
        .ref('uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    // 📊 평균 및 최고 데시벨 계산
    final averageDb = _calculateAverage();
    final peakDb = _decibelValues.isNotEmpty
        ? _decibelValues.reduce((a, b) => a > b ? a : b)
        : averageDb;

    final prompt = NoisePromptBuilder.build(
      averageDb: averageDb,
      peakDb: peakDb,
    );

    await FirebaseFirestore.instance.collection('decibel_analysis').add({
      'average_db': averageDb.toStringAsFixed(2),
      'peak_db': peakDb.toStringAsFixed(2),
      'timestamp': Timestamp.now(),
      'decibel_values': _decibelValues, // 데시벨 데이터 저장
    });

    // 병렬 처리
    final response = await Future.wait([
      FirebaseFirestore.instance.collection('chat_history').add({
        'text': fileName,
        'type': 'audio',
        'url': downloadUrl,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': Timestamp.now(),
      }),
      OpenAIService.analyzeNoise(prompt),
    ]);

    final _ = response[1] as String? ?? "AI 응답 실패";

    final chartMessage = Message(
      content: '소음 분석 그래프',
      type: MessageType.chart,
      timestamp: DateTime.now(),
      chartData: _decibelValues,
    );

    await FirebaseFirestore.instance.collection('chat_history').add({
      'text': chartMessage.content,
      'type': 'chart', // 정확히
      'timestamp': Timestamp.now(),
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'chartData': _decibelValues, // 정확히
    });

    Navigator.pop(context); // Close loading

    _showLoadingDialog(isSuccess: true, width: 200, height: 200); // Show success animation
    await Future.delayed(const Duration(seconds: 3));


    if (mounted) {
      Navigator.pop(context); // Close success animation
      setState(() {
        selectedFormattedDate = DateFormat('yy/MM/dd').format(DateTime.now());
        pendingInput = prompt; // 분석된 입력 저장
        viewMode = ViewMode.detail;
      });
    }
    setState(() {
      _isRecording = false;
      _decibelValues.clear();
      _recordFilePath = null;
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
      viewMode = ViewMode.idle; // 상태를 idle로 리셋
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('녹음이 취소되었습니다.')),
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
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            color: const Color(0xFF58B721),
            dotData: const FlDotData(show: false),
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
    if (mounted && _timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }
//---------------------------------유저 채팅 기록 불러오기 시작---------------------------------
  List<Message> chatHistory = [];
  Future<void> fetchChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('chat_history')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    setState(() {
      chatHistory = snapshot.docs.map((doc) => Message.fromFirestore(doc.data()))
          .where((msg) => msg.type == MessageType.user) // 사용자 메시지만 필터링
          .toList();
    });
  }
//---------------------------------유저 채팅 기록 불러오기 끝---------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('NO!SE GUARD'),
        titleTextStyle: const TextStyle(
          color: Color(0xFF58B721),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () async {
              if (_isRecording) {
                await _cancelRecording(); // ← 녹음 중이면 먼저 종료
              }
              Scaffold.of(context).openDrawer(); // ← 햄버거 누르면 drawer 열기
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPageScreen())),
          ),
        ],
      ),
      //---------------------------------채팅 기록 UI 시작---------------------------------
      drawer: Padding(
        padding: EdgeInsets.only(
          top: kToolbarHeight + MediaQuery.of(context).padding.top,
        ),
        child: Drawer(
          backgroundColor: Colors.grey[900],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 🔒 고정된 제목
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '채팅',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '대화내역',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 📜 아래는 스크롤 가능
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: chatHistory.length,
                  itemBuilder: (context, index) {
                    final message = chatHistory[index];
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title:
                            Text(
                              message.content,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              DateFormat('yyyy.MM.dd HH:mm').format(message.timestamp),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          onTap: () {
                            final message = chatHistory[index];
                            final formattedDate = DateFormat('yy/MM/dd').format(message.timestamp);

                            Navigator.pop(context);
                            setState(() {
                              selectedFormattedDate = formattedDate;
                              viewMode = ViewMode.history;
                            });
                          },
                        ),
                        const Divider(color: Colors.grey),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      //---------------------------------채팅 기록 UI 끝---------------------------------
      body: _isRecording
          ? _buildRecordingView()
          : viewMode == ViewMode.history
            ? ChatHistoryScreen(
              selectedDate: selectedFormattedDate,
              onExit: () {
                setState(() {
                  viewMode = ViewMode.idle;
                });
              },
            )
          : viewMode == ViewMode.detail && selectedFormattedDate != null
            ? ChatDetailScreen(
              dateKey: selectedFormattedDate!,
              initialInput: pendingInput,
            )
          : _buildIdleView(),
    );
  }

  Widget _buildIdleView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Image.asset('assets/logo2.png', width: 105, height: 104),
          const SizedBox(height: 10),
          const Text("스마트한 층간소음 해결", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
          const Text("NO!SE GUARD", style: TextStyle(fontSize: 30, color: Color(0xFF57CC1C), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          const Text("아래의 녹음 버튼을 눌러 소음을 분석해보세요", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF57CC1C), fontWeight: FontWeight.bold)),
          const SizedBox(height: 100),
          GestureDetector(
            onTap: _startRecording,
            child: Image.asset('assets/noise_main/record.png', width: 120, height: 120),
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
            const Text("평균 데시벨 ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
              onTap: () async {
                if (_isRecording) {
                  await _cancelRecording(); // ← 녹음 중이면 먼저 종료
                }

                setState(() {
                  selectedFormattedDate = DateFormat('yy/MM/dd').format(DateTime.now());
                  pendingInput = null; // 분석 요청 없이 채팅만 보기
                  viewMode = ViewMode.detail;
                });
              },
              child: SvgPicture.asset('assets/noise_main/chat.svg', width: 38, height: 38),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: _stopRecording,
              child: SvgPicture.asset('assets/noise_main/recording.svg', width: 140, height: 140),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: _cancelRecording,
              child: SvgPicture.asset('assets/noise_main/trash.svg', width: 38, height: 38),
            ),
          ],
        ),
      ],
    );
  }
}