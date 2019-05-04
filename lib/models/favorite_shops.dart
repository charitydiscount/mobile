class FavoriteShop {
  String userId;
  List<String> shopIds;

  FavoriteShop({this.userId, this.shopIds});

  factory FavoriteShop.fromJson(Map<String, dynamic> json) =>
      FavoriteShop(userId: json['userId'], shopIds: (json['shopId'] as List));
}
