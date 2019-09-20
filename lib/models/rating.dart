class Rating {
  final Reviewer reviewer;
  final double rating;
  final String description;
  final DateTime createdAt;

  Rating({this.reviewer, this.rating, this.description, this.createdAt});

  factory Rating.fromJson(Map json) => Rating(
        reviewer: Reviewer.fromJson(json['reviewer']),
        rating: json['rating'],
        description: json['description'],
        createdAt: json['createdAt'],
      );
}

class Reviewer {
  final String userId;
  final String name;
  final String photoUrl;

  Reviewer({this.userId, this.name, this.photoUrl});

  factory Reviewer.fromJson(Map json) => Reviewer(
        userId: json['userId'],
        name: json['name'] ?? '',
        photoUrl: json['photoUrl'] ?? '',
      );
}
