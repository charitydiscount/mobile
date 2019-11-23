class Product {
  final String id;
  final String title;
  final double price;
  final double oldPrice;
  final int programId;
  final String programName;
  final String brand;
  final String category;
  final String imageUrl;
  final String url;
  String affiliateUrl;
  String programLogo;

  Product({
    this.id,
    this.title,
    this.price,
    this.programId,
    this.programName,
    this.brand,
    this.category,
    this.imageUrl,
    this.url,
    this.oldPrice,
    this.affiliateUrl,
    this.programLogo,
  });

  factory Product.fromJson(Map json) => Product(
        id: json['id'].toString(),
        title: json['title'],
        price: double.tryParse(json['price'].toString()),
        programId: json['programId'],
        programName: json['programName'],
        brand: json['brand'],
        category: json['category'],
        imageUrl: json['imageUrl'] != null &&
                json['imageUrl'].toString().contains(',')
            ? json['imageUrl'].toString().split(',')[0]
            : json['imageUrl'],
        url: json['url'],
        oldPrice: double.tryParse(json['oldPrice'].toString()),
      );

  Product copyWith({
    String id,
    String title,
    double price,
    double oldPrice,
    int programId,
    String programName,
    String brand,
    String category,
    String imageUrl,
    String url,
    String affiliateUrl,
    String programLogo,
  }) =>
      Product(
        id: id ?? this.id,
        title: title ?? this.title,
        price: price ?? this.price,
        programId: programId ?? this.programId,
        programName: programName ?? this.programName,
        brand: brand ?? this.brand,
        category: category ?? this.category,
        imageUrl: imageUrl ?? this.imageUrl,
        url: url ?? this.url,
        oldPrice: oldPrice ?? this.oldPrice,
        affiliateUrl: affiliateUrl ?? this.affiliateUrl,
        programLogo: programLogo ?? this.programLogo,
      );
}

List<Product> productsFromElastic(List json) => List<Product>.from(
      json
          .map((jsonProduct) => Product.fromJson(jsonProduct['_source']))
          .toList(),
    );
