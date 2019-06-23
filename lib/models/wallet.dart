import 'package:charity_discount/models/points.dart';

class Wallet {
  final Points charityPoints;
  final Points cashback;

  Wallet({this.charityPoints, this.cashback});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final cashbackJson = json['cashback'];
    final pointsJson = json['points'];

    final cashback = {
      'approved':
          cashbackJson.containsKey('approved') ? cashbackJson['approved'] : 0,
      'pending':
          cashbackJson.containsKey('pending') ? cashbackJson['pending'] : 0,
    };

    final points = {
      'approved':
          pointsJson.containsKey('approved') ? pointsJson['approved'] : 0,
      'pending': pointsJson.containsKey('pending') ? pointsJson['pending'] : 0,
    };

    return Wallet(
      cashback: Points(
        acceptedAmount: cashback['approved'].toDouble(),
        pendingAmount: cashback['pending'].toDouble(),
      ),
      charityPoints: Points(
        acceptedAmount: points['approved'].toDouble(),
        pendingAmount: points['pending'].toDouble(),
      ),
    );
  }
}
