import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nono/screens/gov_tutorial_screen.dart';
import 'package:nono/screens/police_report_screen.dart';

class ReportSelectionScreen extends StatefulWidget {
  const ReportSelectionScreen({super.key});

  @override
  NotifyPage createState() => NotifyPage();
}

class NotifyPage extends State<ReportSelectionScreen> {
  int? selectedIndex;

  void selectItem(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _handleStart() {
    if (selectedIndex == 0) {
      _connectLink("https://new.land.naver.com/complexes?ms=37.515119,126.906243,17&a=APT:PRE&e=RETAIL");
    } else if (selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GovTutorialScreen()),
      );
    } else if (selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PoliceReportScreen()),
      );
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
              "원하는 신고 탭을\n선택해 주세요",
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
                    title: "관리사무소 전화",
                    description: "거주지 관리사무소에 직접 전화하여\n층간소음 문제를 문의하세요.\n현재 살고 있는 주택을 검색 후\n단지정보에서 전화번호를 탭하여 전화하세요.",
                    imagePath: "assets/call.png",
                  ),
                  _buildSelectableCard(
                    index: 1,
                    title: "정부기관 도움",
                    description: "정부 운영 층간소음 상담센터로 연결됩니다.\n신고 및 상담을 요청할 수 있어요.",
                    imagePath: "assets/gov.png",
                  ),
                  _buildSelectableCard(
                    index: 2,
                    title: "경찰에 신고하기",
                    description: "소음이 심각할 경우 112에 전화하거나 문자로 신고할 수 있어요.",
                    imagePath: "assets/police.png",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                "선택 완료",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 30, height: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
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

  void _connectLink(String url) async {
    final Uri link = Uri.parse(url);
    try {
      await launchUrl(link, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다')),
      );
    }
  }
}
