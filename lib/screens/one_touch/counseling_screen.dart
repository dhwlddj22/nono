import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CounselingScreen extends StatefulWidget {
  const CounselingScreen({super.key});

  @override
  State<CounselingScreen> createState() => _CounselingScreenState();
}

class _CounselingScreenState extends State<CounselingScreen> {
  int? selectedIndex;

  void selectItem(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _handleStart() async {
    if (selectedIndex == 0) {
      final Uri telUri = Uri(scheme: 'tel', path: '16612642');
      await _launchUri(telUri);
    } else if (selectedIndex == 1) {
      final Uri url = Uri.parse('https://floor.noiseinfo.or.kr/floornoise/home/complaint/consultreq.do');
      await _launchUri(url, external: true);
    }
  }

  Future<void> _launchUri(Uri uri, {bool external = false}) async {
    try {
      final launchMode = external ? LaunchMode.externalApplication : LaunchMode.platformDefault;
      final launched = await launchUrl(uri, mode: launchMode);
      if (!launched) throw Exception('launch failed');
    } catch (e) {
      debugPrint('링크 열기 실패: $e');
      _showError('링크를 열 수 없습니다.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "원하는 상담을\n선택해 주세요",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildSelectableCard(
                    index: 0,
                    title: "콜 상담 신청",
                    description: "상담 전용 전화번호로 직접 연결되어\n전문 상담사와 실시간으로 상담을 받을 수 있어요.\n\n복잡한 상황도 즉시 안내와 대응 방법을 들을 수 있어\n빠르고 명확한 도움을 원할 때 유용합니다.",
                    imagePath: "assets/one_touch/one_touch_gov/call_consult.png",
                  ),
                  _buildSelectableCard(
                    index: 1,
                    title: "인터넷 상담 신청",
                    description: "전화 연결이 어렵거나 상황을 글로 설명하고 싶다면,\n인터넷으로 층간소음 상담을 간편하게 할 수 있어요.\n\n전문가가 내용을 확인 후 연락드리며,\n필요 시 전화 상담 또는 측정 예약도 연결됩니다.",
                    imagePath: "assets/one_touch/one_touch_gov/web_consult.png",
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: selectedIndex != null ? _handleStart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedIndex != null ? const Color(0xFF58B721) : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "시작하기",
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableCard({
    required int index,
    required String title,
    required String description,
    required String imagePath,
  }) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => selectItem(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected ? const Color(0xFF58B721) : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 🔥 핵심!
          children: [
            Row(
              children: [
                Image.asset(imagePath, width: 34, height: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons
                      .radio_button_unchecked,
                  color: isSelected ? const Color(0xFF58B721) : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                fontWeight: FontWeight.bold,
                color: Color(0xFF404A50),
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }
}