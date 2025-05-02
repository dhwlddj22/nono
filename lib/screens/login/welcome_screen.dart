import 'package:flutter/material.dart';
import '../main_screen.dart'; // 시작하기 클릭 시 이동할 메인 화면
import 'package:nono/screens/login/onboarding_screen.dart'; // 온보딩 화면으로 이동

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 160, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // ✅ 왼쪽 정렬
                  children: [
                    Text(
                      '층간소음 걱정 없이 편안한 하루를!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        text: '지금부터 소음 문제 해결을 위한\n',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: '스마트한 기능',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: '을 경험해 보세요!🎉',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: Image.asset(
                        'assets/onboarding/signup_onboarding/thumbs_up.png',
                        width: 200, // ✅ 더 크게
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => OnboardingScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58B721),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '시작하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
