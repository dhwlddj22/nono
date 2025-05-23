import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:nono/screens/noise_main/record_screen.dart';
import 'package:nono/screens/one_touch/notify_screen.dart';
import 'package:nono/screens/community/community_screen.dart';
import 'package:nono/screens/law/legal_screen.dart';
import 'package:nono/screens/market/market_screen.dart';
import 'package:nono/screens/one_touch/double_tap.dart';
import 'dart:io'; // exit(0) 사용을 위해 필요

class MainScreen extends StatefulWidget {
  final int selectedIndex;

  const MainScreen({super.key, this.selectedIndex = 2});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late int _selectedIndex;
  late int _previousIndex = 2;
  late final List<AnimationController> _controllers;

  final List<Widget> _pages = [
    const ReportSelectionScreen(),
    CommunityScreen(),
    RecordScreen(),
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
        upperBound: 1.4,
      );
    });
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.stop();
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();

    setState(() {
      _controllers[_selectedIndex].reverse();
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
      _controllers[_selectedIndex].forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await DoubleBackExitHelper.handleDoubleBack(
            context: context,
            onExit: () => exit(0),
          );
        }
      },
      child: Scaffold(
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
            _buildNavItem('assets/bottom_nav/one_touch_report.png', "원터치 신고"),
            _buildNavItem('assets/bottom_nav/noise_community.png', "소음게시판"),
            _buildNavItem('assets/bottom_nav/ai_noise.png', "AI소음측정"),
            _buildNavItem('assets/bottom_nav/law_support.png', "법률지원"),
            _buildNavItem('assets/bottom_nav/noise_market.png', "소음마켓"),
          ],
        ),
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
