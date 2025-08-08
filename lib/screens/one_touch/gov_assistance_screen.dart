import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'counseling_screen.dart'; // 상담 신청 화면

class GovAssistanceScreen extends StatefulWidget {
  const GovAssistanceScreen({super.key});

  @override
  State<GovAssistanceScreen> createState() => _GovAssistanceScreenState();
}

class _GovAssistanceScreenState extends State<GovAssistanceScreen> {
  int? selectedIndex;

  void selectItem(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _handleStart() async {
    if (selectedIndex == null) return;

    switch (selectedIndex) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CounselingScreen()),
        );
        break;
      case 1:
        await _trackGovAction('measure');
        _openUrl("https://floor.noiseinfo.or.kr/floornoise/home/complaint/mesure/nmbrCheck.do");
        break;
      case 2:
        await _trackGovAction('form');
        _openUrl("https://floor.noiseinfo.or.kr/floornoise/home/library.do");
        break;
    }
  }

  Future<void> _trackGovAction(String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final govCollection = userDoc.collection('govActions');

    await govCollection.add({
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final currentCount = (snapshot.data()?['govCount'] ?? 0) as int;
      transaction.set(userDoc, {'govCount': currentCount + 1}, SetOptions(merge: true));
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("링크 열기 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다')),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "원하는 탭을\n선택해 주세요",
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
                    title: "상담 신청",
                    description: "전화 상담 또는 인터넷 상담을 통해 전문가와 함께 상담할 수 있어요.",
                    imagePath: "assets/one_touch/one_touch_gov/consultation.png",
                  ),
                  _buildSelectableCard(
                    index: 1,
                    title: "소음 측정",
                    description: "전문가가 직접 방문하여 소음을 측정하고,\n정확한 데시벨 수치와 기준 초과 여부를 판단해줘요.",
                    imagePath: "assets/one_touch/one_touch_gov/noise_meter.png",
                  ),
                  _buildSelectableCard(
                    index: 2,
                    title: "신청서 양식",
                    description: "각종 신청을 위한 문서를 손쉽게 작성할 수 있도록\n표준화된 신청서 양식을 제공합니다.",
                    imagePath: "assets/one_touch/one_touch_gov/form_icon.png",
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
            color: isSelected ? const Color(0xFF58B721) : Colors.grey.shade300,
            width: 2,
          ),
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
              color: isSelected ? const Color(0xFF58B721) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
