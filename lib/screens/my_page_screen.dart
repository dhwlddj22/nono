import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class MyPageScreen extends StatefulWidget {
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
          title: Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('정말 로그아웃하시겠어요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 취소 버튼
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: _logout, // ✅ 로그아웃 실행
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Log out', style: TextStyle(color: Colors.white)),
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
      MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
          (route) => false, // 기존 화면 제거
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('마이페이지', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // 뒤로가기 버튼
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[800], // 기본 프로필 이미지 배경
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  _user?.displayName ?? '사용자 이름 없음', // ✅ Firebase에서 사용자 이름 가져오기
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _user?.email ?? '이메일 없음', // ✅ Firebase에서 이메일 가져오기
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildListTile('소음 기록', Icons.history),
                _buildListTile('신고 내역', Icons.report),
                _buildListTile('연동 기기', Icons.devices),
                _buildListTile('알림 설정', Icons.notifications),
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
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap, // 클릭 시 실행할 기능
    );
  }
}
