import 'package:charity_discount/models/program.dart';

class FavoriteShops {
  final String userId;
  final Map<String, Program> programs;

  FavoriteShops({this.userId, this.programs});

  factory FavoriteShops.fromJson(Map<String, dynamic> json) => FavoriteShops(
        userId: json['userId'],
        programs: json['programs'] != null
            ? Map<String, dynamic>.from(json['programs'])
                ?.map((key, jsonProgram) {
                Program program = Program.fromJson(jsonProgram);
                program.favorited = true;
                return MapEntry(program.uniqueCode, program);
              })
            : {},
      );
}
