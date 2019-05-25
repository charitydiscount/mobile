import 'package:charity_discount/models/program.dart';

class FavoriteShops {
  String userId;
  List<Program> programs;

  FavoriteShops({this.userId, this.programs});

  factory FavoriteShops.fromJson(Map<String, dynamic> json) => FavoriteShops(
      userId: json['userId'],
      programs: (List.from(json['programs'] ?? []).map((jsonProgram) {
        Program program = Program.fromJson(jsonProgram);
        program.favorited = true;
        return program;
      }).toList()));
}
