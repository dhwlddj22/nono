import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(AssetImage('assets/logo.png'), context); // ✅ 이미지 캐시
      await Future.delayed(Duration(seconds: 2)); // ✅ 스플래시 딜레이

      final user = FirebaseAuth.instance.currentUser; // ✅ 로그인 상태 확인

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => user == null ? LoginScreen() : MainScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 270,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
