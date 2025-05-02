import 'package:flutter/material.dart';
import 'package:nono/screens/law/lawyer.dart';
import 'package:nono/screens/law/detail_screen.dart';


class LegalScreen extends StatelessWidget {
  final List<Lawyer> lawyers = [
    Lawyer(
      name: "김도윤 변호사",
      field: "층간소음 피해 소송",
      phone: "02-3456-7890",
      workingHours: "월-금 10:00 - 18:00",
      image: "assets/lawyers/김도윤.png",
      email: "doyun.kim@lawfirm.com",
      description: "층간소음 관련 법률 자문 및 소송 경험이 풍부한 변호사입니다. 고객의 권리를 보호하기 위해 최선을 다합니다.",
    ),
    Lawyer(
      name: "곽두팔 변호사",
      field: "환경 및 소음 관련 소송",
      phone: "02-8765-4321",
      workingHours: "월-금 09:30 - 17:30",
      image: "assets/lawyers/곽두팔.png",
      email: "kwak.legal@lawfirm.com",
      description: "층간소음 및 환경 분쟁 전문 변호사로, 다년간의 경험을 바탕으로 원만한 해결과 법적 대응을 지원합니다.",
    ),
    Lawyer(
      name: "송윤섭 변호사",
      field: "층간소음 및 부동산 소송",
      phone: "02-5678-1234",
      workingHours: "월-금 10:00 - 17:00",
      image: "assets/lawyers/송윤섭.png",
      email: "ys.song@legalteam.com",
      description: "층간소음, 부동산 관련 법적 분쟁을 전문적으로 다루며, 체계적인 소송 전략으로 고객을 돕습니다.",
    ),
    Lawyer(
      name: "김민지 변호사",
      field: "층간소음 피해 및 손해배상 소송",
      phone: "02-9876-5432",
      workingHours: "월-금 11:00 - 18:00",
      image: "assets/lawyers/김민지.png",
      email: "minji.kim@lawoffice.com",
      description: "층간소음으로 인한 피해 보상 및 법적 절차를 전문적으로 수행하며, 실질적인 해결책을 제공합니다.",
    ),
  ];

  LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "📜 법적 대응이 필요할 때\n확실한 해결책을 찾아보세요.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: lawyers.length,
                itemBuilder: (context, index) {
                  return _buildLawyerCard(context, lawyers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLawyerCard(BuildContext context, Lawyer lawyer) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(lawyer.image),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lawyer.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    lawyer.field,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4),
          Divider(color: Colors.grey.shade300),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.grey, size: 18),
                  SizedBox(width: 4),
                  Text(
                    lawyer.phone,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey, size: 18),
                  SizedBox(width: 4),
                  Text(
                    lawyer.workingHours,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LawyerDetailScreen(lawyer: lawyer)),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              minimumSize: Size(double.infinity, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: Text(
              "Detail",
              style: TextStyle(color: Colors.blue.shade400, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}