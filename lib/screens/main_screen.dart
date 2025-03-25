import 'package:flutter/material.dart';
import 'community_screen.dart'; // ← 반드시 import 해줘

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CommunityScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'NO!SE GUARD',
          style: TextStyle(letterSpacing: 1.2),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.graphic_eq, size: 60, color: Colors.green),
            SizedBox(height: 20),
            Text(
              '스마트한 층간소음 해결, 노이즈가드',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              '녹음파일을 넣어 소음을 분석해보세요.',
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: '원터치 신고',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '소음게시판',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq),
            label: 'AI소음측정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel),
            label: '법률지원',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: '소음마켓',
          ),
        ],
      ),
    );
  }
}
