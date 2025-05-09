import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:nono/screens/noise_main/record_screen.dart';
import 'package:nono/screens/one_touch/notify_screen.dart';
import 'package:nono/screens/community/community_screen.dart';
import 'package:nono/screens/law/legal_screen.dart';
import 'package:nono/screens/market/market_screen.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex; // ✅ 추가

  const MainScreen({super.key, this.selectedIndex = 2}); // ✅ 기본값: 2 (AI 소음측정)

  @override
  _MainScreenState createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late int _selectedIndex; // ✅ 추가

  late int _previousIndex = 2;
  late final List<AnimationController> _controllers;

  final List<Widget> _pages = [
    const ReportSelectionScreen(),
    CommunityScreen(),
    RecordScreen(), // AI 소음 측정 (기본 화면)
    LegalScreen(),
    MarketPage(),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        lowerBound: 1.0,
        upperBound: 1.4, // 커질 크기
      );
    });
    _selectedIndex = widget.selectedIndex; // ✅ 외부에서 받은 값으로 초기화
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    // 진동 효과
    HapticFeedback.lightImpact();

    setState(() {
      _controllers[_selectedIndex].reverse(); // 이전 인덱스 애니메이션 리셋
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
      _controllers[_selectedIndex].forward(); // 선택된 인덱스 애니메이션 시작
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        reverse: _selectedIndex < _previousIndex,
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            child: child,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF58B721),
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _onItemTapped(index),
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
