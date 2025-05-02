import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nono/screens/noise_main/record_screen.dart';
import 'package:nono/screens/one_touch/notify_screen.dart';
import 'package:nono/screens/community/community_screen.dart';
import 'package:nono/screens/law/legal_screen.dart';
import 'package:nono/screens/market/market_screen.dart';
import 'package:nono/screens/one_touch/double_tap.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex; // ✅ 추가

  MainScreen({this.selectedIndex = 2}); // ✅ 기본값: 2 (AI 소음측정)

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // 0: 원터치 신고
    GlobalKey<NavigatorState>(), // 1: 소음게시판
    GlobalKey<NavigatorState>(), // 2: AI소음측정
    GlobalKey<NavigatorState>(), // 3: 법률지원
    GlobalKey<NavigatorState>(), // 4: 소음마켓
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // ✅ 외부에서 받은 값으로 초기화
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldExit = await DoubleBackExitHelper.handleDoubleBack(
          context: context,
          onExit: () => SystemNavigator.pop(),
        );

        if (shouldExit) SystemNavigator.pop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
            _buildOffstageNavigator(3),
            _buildOffstageNavigator(4),
          ],
        ),
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
      ),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) {
              switch (index) {
                case 0:
                  return ReportSelectionScreen();
                case 1:
                  return CommunityScreen();
                case 2:
                  return RecordScreen();
                case 3:
                  return LegalScreen();
                case 4:
                  return MarketPage();
                default:
                  return Container();
              }
            },
          );
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
