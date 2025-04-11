import 'package:flutter/material.dart';
import 'package:nono/screens/record_screen.dart';
import 'notify_screen.dart';
import 'community_screen.dart';
import 'package:nono/legal_assistance/legal_screen.dart';
import 'package:nono/market/market_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // 기본값: AI 소음 측정 페이지

  final List<Widget> _pages = [
    ReportSelectionScreen(),
    CommunityScreen(),
    RecordScreen(), // AI 소음 측정 (기본 화면)
    LegalScreen(),
    MarketPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF58B721),
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          _buildNavItem(Icons.lightbulb_outline, "원터치 신고"),
          _buildNavItem(Icons.chat_bubble_outline, "소음게시판"),
          _buildNavItem(Icons.adb, "AI소음측정"),
          _buildNavItem(Icons.gavel, "법률지원"),
          _buildNavItem(Icons.shopping_bag_outlined, "소음마켓"),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }
}
