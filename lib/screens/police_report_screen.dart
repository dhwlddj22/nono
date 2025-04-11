import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PoliceReportScreen extends StatefulWidget {
  const PoliceReportScreen({super.key});

  @override
  State<PoliceReportScreen> createState() => _PoliceReportScreenState();
}

class _PoliceReportScreenState extends State<PoliceReportScreen> {
  int? selectedIndex;

  void selectItem(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _handleSubmit() async {
    if (selectedIndex == 0) {
      final Uri smsUri = Uri(scheme: 'sms', path: '112', queryParameters: {
        'body':
        '[층간소음 신고]\n주소: 서울시 ○○구 ○○동 ○○아파트 ○○동 ○○호\n신고 내용: 지속적인 층간소음 피해 발생\n시간대: 오늘 오후 8시부터 현재까지\n내용: 쿵쿵거리는 소리, 발망치, 가구 끄는 소리 반복\n피해 상황: 아기가 잠을 자지 못하고 있어 정신적으로 스트레스를 받고 있음',
      });
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        _showError('문자 앱을 열 수 없습니다.');
      }
    } else if (selectedIndex == 1) {
      final Uri telUri = Uri(scheme: 'tel', path: '112');
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        _showError('전화 연결이 불가능합니다.');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/big_police.png', width: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '경찰에 신고하기',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            '허위 신고는 처벌될 수 있어요!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset('assets/warning_icon.png', width: 14),
                        ]
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            _buildSelectableCard(
              index: 0,
              title: '문자로',
              description:
              '층간소음 신고 문자 양식을 바탕으로\n간편하게 작성할 수 있어요.',
              example: '예시)\n주소: 서울시 ○○구 ○○동 ○○아파트 ○○동 ○○호\n신고 내용: 지속적인 층간소음 피해 발생\n시간대: 오늘 오후 8시부터 현재까지\n내용: 쿵쿵거리는 소리, 발망치, 가구 끄는 소리 반복\n피해 상황: 아기가 잠을 자지 못하고 있어 정신적으로 스트레스를 받고 있음',
              imagePath: 'assets/message.png',
            ),
            _buildSelectableCard(
              index: 1,
              title: '전화로',
              description: '한 번의 클릭으로 경찰에 전화할 수 있어요.',
              imagePath: 'assets/phone.png',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedIndex != null ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedIndex != null ? const Color(0xFF58B721) : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "선택 완료",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableCard({
    required int index,
    required String title,
    required String description,
    required String imagePath,
    String? example,
  }) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => selectItem(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF58B721) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(imagePath, width: 28, height: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF58B721) : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF404A50),
                fontWeight: FontWeight.bold,
                height: 1.5,
                fontFamily: 'Pretendard',
              ),
            ),
            if (example != null) ...[
              const SizedBox(height: 12),
              Text(
                example,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  fontFamily: 'Pretendard',
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
