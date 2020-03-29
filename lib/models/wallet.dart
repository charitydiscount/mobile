import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/models/points.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet.g.dart';

class Wallet {
  final Points charityPoints;
  final Points cashback;
  final List<Transaction> transactions;

  Wallet({this.charityPoints, this.cashback, this.transactions});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final cashbackJson = json['cashback'];
    final pointsJson = json['points'];
    final transactionsJson = json['transactions'] ?? [];

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

    final transactions = List<Transaction>.from(
      transactionsJson.map((txJson) => Transaction.fromJson(txJson)).toList(),
    );

    return Wallet(
      cashback: Points(
        acceptedAmount: cashback['approved'].toDouble(),
        pendingAmount: cashback['pending'].toDouble(),
      ),
      charityPoints: Points(
        acceptedAmount: points['approved'].toDouble(),
        pendingAmount: points['pending'].toDouble(),
      ),
      transactions: transactions,
    );
  }
}

enum TxType { DONATION, CASHOUT, BONUS, COMMISSION, REFERRAL }

TxType txTypeFromString(String txTypeString) {
  String txTypeUpper = txTypeString.toUpperCase();
  String txEnumString = 'TxType.$txTypeUpper';
  return TxType.values.firstWhere(
    (f) => f.toString() == txEnumString,
    orElse: () => null,
  );
}

class Transaction {
  final TxType type;
  final DateTime date;
  final double amount;
  final String currency;
  final Target target;

  Transaction({
    this.type,
    this.date,
    this.amount,
    this.currency,
    this.target,
  });

  factory Transaction.fromJson(dynamic json) => Transaction(
        type: txTypeFromString(json["type"] as String),
        date: (json["date"] as Timestamp).toDate(),
        amount: json['amount'] != null ? json['amount'].toDouble() : null,
        currency: json['currency'] ?? 'RON',
        target: Target.fromJson(json['target']),
      );
}

@JsonSerializable()
class Target {
  final String id;
  final String name;

  Target({this.id, this.name});

  factory Target.fromJson(dynamic json) => json is String
      ? Target(
          id: json,
          name: '',
        )
      : _$TargetFromJson(Map.from(json));

  Map<String, dynamic> toJson() => _$TargetToJson(this);
}
