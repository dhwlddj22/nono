import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "원터치 신고 페이지",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}