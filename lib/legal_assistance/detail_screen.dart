import 'package:flutter/material.dart';
import 'package:nono/domain/lawyer.dart';

class LawyerDetailScreen extends StatelessWidget {
  final Lawyer lawyer;

  const LawyerDetailScreen({super.key, required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 10,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 큰 이미지와 버튼을 겹쳐 배치
            Stack(
              children: [
                // 변호사 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    lawyer.image,
                    width: double.infinity,
                    height: 450,
                    fit: BoxFit.cover,
                  ),
                ),
                // 🔥 이미지 안에 버튼 배치
                SafeArea(
                  child: Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lawyer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lawyer.field,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.grey, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        lawyer.phone,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, color: Colors.grey, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        lawyer.workingHours,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "안녕하세요, 변호사 ${lawyer.name}입니다. 👋",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lawyer.description,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
