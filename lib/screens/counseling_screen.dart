import 'package:flutter/material.dart';

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

  void _handleStart() {
    if (selectedIndex == 0) {
      // 콜 상담 로직
      print("콜 상담 신청 선택됨");
      // 예: 전화 연결 or 연결 링크
    } else if (selectedIndex == 1) {
      // 인터넷 상담 로직
      print("인터넷 상담 신청 선택됨");
      // 예: 양식 제출 화면 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
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
                    imagePath: "assets/call_consult.png",
                  ),
                  _buildSelectableCard(
                    index: 1,
                    title: "인터넷 상담 신청",
                    description: "전화 연결이 어렵거나 상황을 글로 설명하고 싶다면,\n인터넷으로 층간소음 상담을 간편하게 할 수 있어요.\n\n전문가가 내용을 확인 후 연락드리며,\n필요 시 전화 상담 또는 측정 예약도 연결됩니다.",
                    imagePath: "assets/web_consult.png",
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: selectedIndex != null ? _handleStart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedIndex != null ? Colors.blue : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "시작하기",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath, width: 32, height: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
