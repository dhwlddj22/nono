import 'package:flutter/material.dart';

class DoubleBackExitHelper {
  static DateTime? _lastBackPressTime;

  static Future<bool> handleDoubleBack({
    required BuildContext context,
    required VoidCallback onExit,
  }) async {
    final now = DateTime.now();
    final isDoublePress = _lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2);

    if (isDoublePress) {
      onExit();
      return true;
    }

    _lastBackPressTime = now;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('한 번 더 누르면 앱이 종료됩니다')),
    );
    return false;
  }
}
