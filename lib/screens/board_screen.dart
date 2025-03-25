import 'package:flutter/material.dart';

class BoardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "소음 게시판 페이지",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}