// 변호사 데이터 모델
class Lawyer {
  final String name;
  final String field;
  final String phone;
  final String workingHours;
  final String image;
  final String email;
  final String description;

  Lawyer({
    required this.name,
    required this.field,
    required this.phone,
    required this.workingHours,
    required this.image,
    required this.email,
    required this.description,
  });
}