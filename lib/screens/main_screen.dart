import 'package:flutter/material.dart';
import 'package:nono/screens/noise_main/record_screen.dart';
import 'one_touch/notify_screen.dart';
import 'community/community_screen.dart';
import 'package:nono/screens/law/legal_screen.dart';
import 'package:nono/screens/market/market_screen.dart';

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
          _buildNavItem('assets/bottom_nav/one_touch_report.png', "원터치 신고"),
          _buildNavItem('assets/bottom_nav/noise_community.png', "소음게시판"),
          _buildNavItem('assets/bottom_nav/ai_noise.png', "AI소음측정"),
          _buildNavItem('assets/bottom_nav/law_support.png', "법률지원"),
          _buildNavItem('assets/bottom_nav/noise_market.png', "소음마켓"),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String assetPath, String label) {
    return BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage(assetPath),
        color: Colors.white,
      ),
      activeIcon: ImageIcon(
        AssetImage(assetPath),
        color: Color(0xFF57CC1C),
      ),
      label: label,
    );
  }
}
