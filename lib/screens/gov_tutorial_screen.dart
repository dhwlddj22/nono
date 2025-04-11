import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'tutorial_text_styles.dart';

class GovTutorialScreen extends StatefulWidget {
  const GovTutorialScreen({super.key});

  @override
  State<GovTutorialScreen> createState() => _GovTutorialScreenState();
}

class _GovTutorialScreenState extends State<GovTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _canStart = false;

  @override
  void initState() {
    super.initState();
    _markAsSeen(); // optional if you want to pre-flag before pressing 시작하기
  }

  Future<void> _markAsSeen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.set({'govTutorialSeen': true}, SetOptions(merge: true));
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      _canStart = index == 2;
    });
  }

  Future<void> _onStart() async {
    await _markAsSeen(); // ✅ 실제로 "시작하기" 눌렀을 때 저장
    Navigator.pop(context, true); // true 반환하여 ReportSelectionScreen에서 확인
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                    dotColor: Colors.grey.shade700,
                    activeDotColor: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildPage(
                    title: 'Understand',
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "층간소음은 단순한 소음 문제가 아닙니다.\n\n"
                              "이웃 간의 갈등으로 번지고,\n"
                              "일상과 마음 건강에도 큰 영향을 줄 수 있는\n\n"
                              "사회적 문제입니다.\n\n"
                              "이를 해결하기 위해 정부가 설립한 공공기관이",
                          style: tutorialBodyStyle,
                        ),
                        const SizedBox(height: 10),
                        Text("층간소음 이웃사이센터입니다.", style: tutorialHighlightStyle),
                      ],
                    ),
                    imageRow: [
                      Image.asset('assets/tutorial_1_1.png', width: 130),
                      Image.asset('assets/tutorial_1_2.png', width: 130),
                    ],
                  ),
                  _buildPage(
                    title: 'Support',
                    body: Text(
                      "이웃사이센터는 중립적인 입장에서\n이웃 간 갈등을 중재합니다.\n\n"
                          "전화/인터넷 상담, 전문가 방문 소음 측정, 문제 조정까지\n\n"
                          "전 과정을 무료로 지원하며,\n"
                          "법적 다툼 없이도 해결할 수 있도록 도와줍니다.",
                      style: tutorialBodyStyle,
                    ),
                    imageRow: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset('assets/tutorial_2.png', width: 340, height: 300),
                        ],
                      ),
                    ],
                  ),
                  _buildPage(
                    title: 'Start',
                    body: Text(
                      "혼자 고민하지 마세요.\n\n층간소음 문제, 이웃사이센터가 함께합니다.\n\n"
                          "• 매일 소음으로 고통받는 분\n"
                          "• 감정 싸움 없이 해결하고 싶은 분\n"
                          "• 법적 대응 전 도움을 받고 싶은 분\n"
                          "• 객관적인 소음 측정이 필요한 분",
                      style: tutorialBodyStyle,
                    ),
                    imageRow: [
                      Image.asset('assets/tutorial_3.png', width: 250),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canStart ? _onStart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canStart ? const Color(0xFF58B721) : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required Widget body,
    required List<Widget> imageRow,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(title, style: tutorialTitleStyle),
          const SizedBox(height: 20),
          body,
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imageRow,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
