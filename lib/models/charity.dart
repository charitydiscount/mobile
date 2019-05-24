class Charity {
  String id;
  String title;
  String description;
  List<CharityImage> images;

  Charity({this.id, this.title, this.description, this.images});

  factory Charity.fromJson(Map<String, dynamic> json) => Charity(
        title: json["title"] as String,
        description: json["description"] as String,
        images: (json["images"] as List)
            ?.map((img) => img == null
                ? null
                : CharityImage.fromJson(Map<String, String>.from(img)))
            ?.toList(),
      );
}

class CharityImage {
  String url;

  CharityImage({this.url});

  factory CharityImage.fromJson(Map<String, dynamic> json) => CharityImage(
        url: json["url"] as String,
      );
}
