import 'package:flutter/material.dart';
import 'main_screen.dart'; // 메인 화면으로 이동

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '층간소음 걱정 없이 편안한 하루를!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Pretendard', // Pretendard 폰트 적용
                fontWeight: FontWeight.w700, // Bold (700)
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 22),
            Text.rich(
              TextSpan(
                text: '지금부터 소음 문제 해결을 위한\n',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: '스마트한 기능',
                    style: TextStyle(
                      fontWeight: FontWeight.w900, // 더 굵게
                    ),
                  ),
                  TextSpan(
                    text: '을 경험해 보세요! 🎉',
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 40),
            Image.asset('assets/thumbs_up.png', width: 120), // 👍 이모지 이미지
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('시작하기', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
