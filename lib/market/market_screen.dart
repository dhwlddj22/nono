import 'package:flutter/material.dart';
import 'package:nono/domain/product.dart';
import 'package:nono/market/market_detail_screen.dart';

class MarketPage extends StatelessWidget {
  final List<Product> products = [
    Product(
      name: "소음 방지 러그",
      brand: "SilentHome",
      shortDescription: "층간소음을 줄여주는 두꺼운 러그",
      description: "두꺼운 소재로 제작되어 층간소음을 효과적으로 줄여주며, 미끄럼 방지 기능까지 갖춘 러그입니다.",
      price: "₩49,900",
      image: "assets/rug.png",
      rating: 4.5,
      reviews: 6800,
      link: "https://example.com/rug",
    ),
    Product(
      name: "방음 폼 패널",
      brand: "QuietWall",
      shortDescription: "벽에 붙여 소음을 차단하는 패널",
      description: "흡음재로 제작되어 소음을 차단하고, 공간을 더욱 조용하게 만들어주는 방음 패널입니다.",
      price: "₩39,900",
      image: "assets/soundproof_panel.png",
      rating: 4.8,
      reviews: 15234,
      link: "https://example.com/soundproof_panel",
    ),
    Product(
      name: "두꺼운 커튼",
      brand: "SoundShield",
      shortDescription: "소음과 빛을 차단하는 방음 커튼",
      description: "특수한 방음 소재가 적용된 커튼으로, 외부 소음을 효과적으로 줄여 조용한 환경을 조성해줍니다.",
      price: "₩29,900",
      image: "assets/thick_curtain.png",
      rating: 4.6,
      reviews: 52346,
      link: "https://example.com/thick_curtain",
    ),
    Product(
      name: "문틈 방음 테이프",
      brand: "SealQuiet",
      shortDescription: "문틈 소음을 줄여주는 실리콘 테이프",
      description: "문틈 사이의 공간을 밀폐하여 소음과 외부 공기를 차단해 주는 방음 테이프입니다.",
      price: "₩9,900",
      image: "assets/door_tape.png",
      rating: 4.7,
      reviews: 45878,
      link: "https://example.com/door_tape",
    ),
    Product(
      name: "층간소음 매트",
      brand: "SoftStep",
      shortDescription: "어린이 소음 방지를 위한 쿠션 매트",
      description: "특수 소재로 제작된 층간소음 방지 매트로, 아이들의 뛰는 소음을 효과적으로 줄여줍니다.",
      price: "₩59,900",
      image: "assets/floor_mat.png",
      rating: 4.9,
      reviews: 33566,
      link: "https://example.com/floor_mat",
    ),
    Product(
      name: "소음 차단 이어폰",
      brand: "NoiseBlock",
      shortDescription: "집중력을 높여주는 노이즈 캔슬링 이어폰",
      description: "액티브 노이즈 캔슬링 기술이 적용되어 주변 소음을 차단하고 몰입도를 높여주는 이어폰입니다.",
      price: "₩99,900",
      image: "assets/noise_canceling_earphones.png",
      rating: 4.8,
      reviews: 27344,
      link: "https://example.com/noise_canceling_earphones",
    ),
  ];


  MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 타이틀
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.campaign, color: Colors.redAccent, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "층간소음 완화 아이템을 추천하고\n구매할 수 있는 공간입니다.",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // 상품 목록
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product), // product 전달
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          // child: Image.asset(product.image, width: 20, height: 20),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text(product.brand, style: TextStyle(color: Colors.grey[400])),
                        trailing: Text(product.price, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
