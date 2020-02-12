class ProductSearchResult {
  final List<Product> products;
  final int totalFound;

  ProductSearchResult(this.products, this.totalFound);
}

class Product {
  final String id;
  final String title;
  final double price;
  final double oldPrice;
  final String programId;
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
        id: json['product_id'] != null
            ? json['product_id'].toString()
            : json['id'].toString(),
        title: json['title'],
        price: double.tryParse(json['price'].toString()),
        programId:
            json['campaign_id'].toString() ?? json['programId'].toString(),
        programName: json['campaign_name'] ?? json['programName'],
        brand: json['brand'],
        category: json['category'],
        imageUrl: json['image_urls'] != null
            ? _getImageUrl(json, 'image_urls')
            : _getImageUrl(json, 'imageUrl'),
        url: json['url'],
        oldPrice: double.tryParse(json['old_price'].toString()),
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

String _getImageUrl(dynamic json, String key) =>
    json[key] != null && json[key].toString().contains(',')
        ? json[key].toString().split(',')[0]
        : json[key];

List<Product> productsFromElastic(List json) => List<Product>.from(
      json
          .map((jsonProduct) => Product.fromJson(jsonProduct['_source']))
          .toList(),
    );
