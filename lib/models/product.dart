import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/util/tools.dart';

class ProductSearchResult {
  final List<Product> products;
  final int totalFound;

  ProductSearchResult(this.products, this.totalFound);
}

class ProductPriceHistoryEntry {
  final DateTime timestamp;
  final double price;
  final double oldPrice;

  ProductPriceHistoryEntry({this.timestamp, this.price, this.oldPrice});

  factory ProductPriceHistoryEntry.fromJson(Map json) =>
      ProductPriceHistoryEntry(
        timestamp: DateTime.parse(json['@timestamp']),
        price: double.tryParse(json['price'].toString()),
        oldPrice: double.tryParse(json['old_price'].toString()),
      );
}

class ProductPriceHistory {
  final String productId;
  final List<ProductPriceHistoryEntry> history;

  ProductPriceHistory(this.productId, this.history);
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
  final List<String> images;
  final String url;
  final DateTime timestamp;
  String affiliateUrl;
  Program program;

  Product({
    this.id,
    this.title,
    this.price,
    this.programId,
    this.programName,
    this.brand,
    this.category,
    this.images,
    this.url,
    this.oldPrice,
    this.affiliateUrl,
    this.program,
    this.timestamp,
  });

  factory Product.fromJson(Map json) => Product(
        id: json['product_id'] != null
            ? json['aff_code']
            : json['id'].toString(),
        title: removeAllHtmlTags(json['title']),
        price: double.tryParse(json['price'].toString()),
        programId:
            json['campaign_id'].toString() ?? json['programId'].toString(),
        programName: json['campaign_name'] ?? json['programName'],
        brand: json['brand'],
        category: json['category'],
        images: json['image_urls'] != null
            ? _getImages(json, 'image_urls')
            : _getImages(json, 'imageUrl'),
        url: json['url'],
        oldPrice: double.tryParse(json['old_price'].toString()),
        timestamp: DateTime.parse(json['@timestamp']),
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
    String images,
    String url,
    String affiliateUrl,
    Program program,
    DateTime timestamp,
  }) =>
      Product(
        id: id ?? this.id,
        title: title ?? this.title,
        price: price ?? this.price,
        programId: programId ?? this.programId,
        programName: programName ?? this.programName,
        brand: brand ?? this.brand,
        category: category ?? this.category,
        images: images ?? this.images,
        url: url ?? this.url,
        oldPrice: oldPrice ?? this.oldPrice,
        affiliateUrl: affiliateUrl ?? this.affiliateUrl,
        program: program ?? this.program,
        timestamp: timestamp ?? this.timestamp,
      );
}

List<String> _getImages(dynamic json, String key) =>
    json[key] != null && json[key].toString().contains(',')
        ? json[key].toString().split(',').map((img) => img.trim()).toList()
        : [json[key]];

List<Product> productsFromElastic(List json) => List<Product>.from(
      json
          .map((jsonProduct) => Product.fromJson(jsonProduct['_source']))
          .toList(),
    );

List<ProductPriceHistoryEntry> productHistoryFromElastic(List json) =>
    List<ProductPriceHistoryEntry>.from(
      json
          .map(
            (jsonProduct) =>
                ProductPriceHistoryEntry.fromJson(jsonProduct['_source']),
          )
          .toList(),
    );
