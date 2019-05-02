class FavoriteShop {
  String shopId;
  String userId;

  FavoriteShop({this.shopId, this.userId});

  factory FavoriteShop.fromJson(Map<String, dynamic> json) =>
      FavoriteShop(shopId: json['shopId'], userId: json['userId']);
}
