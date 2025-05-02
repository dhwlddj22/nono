import 'package:flutter/material.dart';
import 'package:nono/screens/market/product.dart';
import 'package:nono/screens/market/market_detail_screen.dart';

class MarketPage extends StatelessWidget {
  final List<Product> products = [
    Product(
      name: "이어플러그",
      brand: "3M",
      shortDescription: "이어플러그",
      description: "숙면을 위한 최고의 아이템입니다.",
      price: "1,000원",
      image: "assets/market/products/이어플러그.jpeg",
      rating: 4.5,
      reviews: 6800,
      link: "https://example.com/rug",
    ),
    Product(
      name: "방음 폼 패널",
      brand: "QuietWall",
      shortDescription: "벽에 붙여 소음을 차단하는 패널",
      description: "흡음재로 제작되어 소음을 차단하고, 공간을 더욱 조용하게 만들어주는 방음 패널입니다.",
      price: "39,900원",
      image: "assets/market/products/방음폼.jpeg",
      rating: 4.8,
      reviews: 15234,
      link: "https://example.com/soundproof_panel",
    ),
    Product(
      name: "두꺼운 커튼",
      brand: "SoundShield",
      shortDescription: "소음과 빛을 차단하는 방음 커튼",
      description: "특수한 방음 소재가 적용된 커튼으로, 외부 소음을 효과적으로 줄여 조용한 환경을 조성해줍니다.",
      price: "29,900원",
      image: "assets/market/products/두꺼운 커튼.jpeg",
      rating: 4.6,
      reviews: 52346,
      link: "https://example.com/thick_curtain",
    ),
    Product(
      name: "문틈 방음 테이프",
      brand: "SealQuiet",
      shortDescription: "문틈 소음을 줄여주는 실리콘 테이프",
      description: "문틈 사이의 공간을 밀폐하여 소음과 외부 공기를 차단해 주는 방음 테이프입니다.",
      price: "9,900원",
      image: "assets/market/products/방음 문틈 테이프.jpeg",
      rating: 4.7,
      reviews: 45878,
      link: "https://example.com/door_tape",
    ),
    Product(
      name: "층간소음 매트",
      brand: "SoftStep",
      shortDescription: "어린이 소음 방지를 위한 쿠션 매트",
      description: "특수 소재로 제작된 층간소음 방지 매트로, 아이들의 뛰는 소음을 효과적으로 줄여줍니다.",
      price: "59,900원",
      image: "assets/market/products/층간소음 매트.jpeg",
      rating: 4.9,
      reviews: 33566,
      link: "https://example.com/floor_mat",
    ),
    Product(
      name: "소음 차단 이어폰",
      brand: "NoiseBlock",
      shortDescription: "집중력을 높여주는 노이즈 캔슬링 이어폰",
      description: "액티브 노이즈 캔슬링 기술이 적용되어 주변 소음을 차단하고 몰입도를 높여주는 이어폰입니다.",
      price: "99,900원",
      image: "assets/market/products/소음차단이어폰.jpeg",
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const SizedBox.shrink(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // 페이지 상단 안내문구
            const Row(
              children: [
                Image(
                  image: AssetImage("assets/market/market.png"), // 이미지 경로
                  width: 40, // 아이콘과 비슷한 크기
                  height: 40,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "층간소음 완화 아이템을 추천하고\n구매할 수 있는 공간입니다.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      // 상세 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 제품 이미지
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  product.image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // 제품명과 브랜드
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      product.brand,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // 가격 위치를 오른쪽 아래로 배치
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product.price,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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
