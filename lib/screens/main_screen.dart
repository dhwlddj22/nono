import 'package:flutter/material.dart';
import 'my_page_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isSettingsPressed = false; // ✅ 버튼 클릭 여부 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NO!SE GUARD', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: _isSettingsPressed ? Colors.green : Colors.grey, // ✅ 색상 변경
            ),
            onPressed: () {
              setState(() {
                _isSettingsPressed = true; // ✅ 클릭 시 초록색으로 변경
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPageScreen()),
              ).then((_) {
                setState(() {
                  _isSettingsPressed = false; // ✅ 마이페이지에서 돌아오면 회색으로 복구
                });
              });
            },
          ),
        ],
      ),
      body: Center(child: Text('메인 화면 내용')),
    );
  }
}
