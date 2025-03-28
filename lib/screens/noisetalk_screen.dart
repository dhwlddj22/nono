import 'package:flutter/material.dart';
// 임시 페이지
class NoiseTalkScreen extends StatelessWidget {
  const NoiseTalkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('소음톡 페이지', style: TextStyle(color: Colors.white))),
    );
  }
}