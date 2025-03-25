import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Firebase 추가
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(); // ✅ Firebase 초기화
  } catch (e) {
    print("🔥 Firebase 초기화 오류: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        ),
        fontFamily: 'Pretendard', // 앱 전체에 Pretendard 폰트 적용
        brightness: Brightness.dark, // 기존의 다크 테마 유지
      ),
      home: SplashScreen(),
    );
  }
}
