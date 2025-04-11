import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 이미지 미리 로딩 → 화면 깜빡임 방지
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(AssetImage('assets/logo.png'), context); // ✅ 이미지 미리 캐시
      await Future.delayed(Duration(seconds: 1)); // 지연 (1초로 수정)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 270,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(height: 20),
                  const Text(
                    '스마트한 층간소음 해결',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'NO!SE GUARD',
                    style: TextStyle(
                      color: const Color(0xFF58B721),
                      fontSize: 24,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'NO!SE GUARD',
                  style: TextStyle(
                    color: const Color(0xFF58B721),
                    fontSize: 24,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
          */
        ],
      ),
    );
  }
}
