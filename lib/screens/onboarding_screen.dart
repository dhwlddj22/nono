import 'package:flutter/material.dart';
import 'main_screen.dart'; // 메인 화면으로 이동

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: '실시간 녹음\n소음 측정',
      description: '내가 느끼는 불쾌한 소음,\n수치로 정확하게 확인해보세요.',
      imagePath: 'assets/onboarding2.png',
    ),
    _OnboardingData(
      title: '녹음 파일\n안전하게 저장하기',
      description: '녹음된 파일은 자동으로 저장돼요\n언제든 다시 확인하고 활용할 수 있어요.',
      imagePath: 'assets/onboarding1.png',
    ),
    _OnboardingData(
      title: 'AI가\n녹음 파일을 분석해줘요',
      description: '녹음된 파일은 자동으로 저장돼요\n언제든 다시 확인하고 활용할 수 있어요.',
      imagePath: 'assets/onboarding3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // 우측 상단 점 인디케이터
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildIndicator(),
              ),
            ),
            const SizedBox(height: 20),
            // 온보딩 페이지 뷰
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF58B721),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          page.description,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            height: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 90),
                        Flexible(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: _getImageLeftPadding(index),
                              ),
                              child: Image.asset(
                                page.imagePath,
                                fit: BoxFit.contain,
                                width:
                                MediaQuery.of(context).size.width * 0.8,
                                height:
                                MediaQuery.of(context).size.height * 0.30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // 시작하기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _currentPage == _pages.length - 1
                    ? () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ),
                  );
                }
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _currentPage == _pages.length - 1
                        ? const Color(0xFF58B721)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '시작하기',
                    style: TextStyle(
                      color: _currentPage == _pages.length - 1
                          ? Colors.white
                          : Colors.white38,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _pages.length,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }

  double _getImageLeftPadding(int index) {
    switch (index) {
      case 0:
        return 23;
      case 1:
        return 5;
      case 2:
        return 13;
      default:
        return 20;
    }
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
