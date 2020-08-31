class Charity {
  String id;
  final String title;
  final String description;
  final List<CharityImage> images;
  final String site;

  Charity({
    this.id,
    this.title,
    this.description,
    this.images,
    this.site,
  });

  factory Charity.fromJson(Map<String, dynamic> json) => Charity(
        title: json['title'] as String,
        description: json['description'] as String,
        images: (json['images'] as List)
            ?.map(
              (img) => img == null
                  ? null
                  : CharityImage.fromJson(
                      Map<String, String>.from(img),
                    ),
            )
            ?.toList(),
        site: json['site'] ?? null,
      );
}

class CharityImage {
  final String url;

  CharityImage({this.url});

  factory CharityImage.fromJson(Map<String, dynamic> json) => CharityImage(
        url: json['url'] as String,
      );
}
