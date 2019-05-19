import 'package:charity_discount/models/program.dart';

class FavoriteShop {
  String userId;
  List<String> shopIds;

  FavoriteShop({this.userId, this.shopIds});

  factory FavoriteShop.fromJson(Map<String, dynamic> json) =>
      FavoriteShop(userId: json['userId'], shopIds: (json['shopId'] as List));
}

class FavoriteShops {
  String userId;
  List<Program> programs;

  FavoriteShops({this.userId, this.programs});

  factory FavoriteShops.fromJson(Map<String, dynamic> json) => FavoriteShops(
      userId: json['userId'],
      programs: (List.from(json['programs'] ?? [])
          .map((jsonProgram) => Program.fromJson(jsonProgram))));
}
