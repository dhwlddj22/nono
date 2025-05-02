import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'noise_analysis_screen.dart';

class NoiseAnalysisChatScreenWithNav extends StatelessWidget {
  final String? initialInput;

  NoiseAnalysisChatScreenWithNav({this.initialInput});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoiseAnalysisChatScreen(initialInput: initialInput),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.white,
          currentIndex: 2,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainScreen(selectedIndex: index),
              ),
            );
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: "원터치 신고"),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "소음게시판"),
            BottomNavigationBarItem(icon: Icon(Icons.adb), label: "AI소음측정"),
            BottomNavigationBarItem(icon: Icon(Icons.gavel), label: "법률지원"),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "소음마켓"),
          ],
        )

    );
  }
}
