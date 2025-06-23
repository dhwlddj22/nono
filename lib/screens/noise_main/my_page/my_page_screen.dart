import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../login/login_screen.dart';
import 'noise_history_screen.dart';
import 'notification_settings_screen.dart';


class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  User? _user; // Firebase 사용자 정보

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  // ✅ 현재 로그인한 사용자 정보 가져오기
  void _getUserInfo() {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  // ✅ 로그아웃 다이얼로그 표시
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 탭하면 닫힘
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // ✅ 모달 창 둥글게
          backgroundColor: Colors.white,
          title: const Text(
              '로그아웃',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black

              )
          ),
          content: const Text(
            '정말 로그아웃하시겠어요?',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context), // 취소 버튼
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white
              ),
              child: const Text(
                  '취소',
                  style: TextStyle(
                    color: Color(0xFF58B721)
                  )
              ),
            ),
            const SizedBox(width: 40),
            ElevatedButton(
              onPressed: _logout, // ✅ 로그아웃 실행
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58B721)
              ),
              child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.white
                  )
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ 로그아웃 기능
  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Firebase 로그아웃
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), // 로그인 화면으로 이동
          (route) => false, // 기존 화면 제거
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('NO!SE GUARD'),
        titleTextStyle: const TextStyle(
          color: Color(0xFF58B721),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white), // 뒤로가기 버튼
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[800], // 기본 프로필 이미지 배경
                  child: const Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  _user?.displayName ?? '사용자 이름 없음', // ✅ Firebase에서 사용자 이름 가져오기
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _user?.email ?? '이메일 없음', // ✅ Firebase에서 이메일 가져오기
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildListTile(
                  '소음 기록',
                  Icons.history,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NoiseHistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildListTile('신고 내역', Icons.report),
                _buildListTile('연동 기기', Icons.devices),
              _buildListTile(
                  '알림 설정', Icons.notifications,
                  onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (_) => const NotificationSettingsScreen(),
                     ),
                   );
                 },
              ),
                _buildListTile('테마 및 UI 설정', Icons.palette),
                _buildListTile('언어 설정', Icons.language),
                _buildListTile('개인 정보 보호', Icons.lock),
                _buildListTile('로그아웃', Icons.logout, onTap: _showLogoutDialog), // ✅ 로그아웃 모달 띄우기
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap, // 클릭 시 실행할 기능
    );
  }
}