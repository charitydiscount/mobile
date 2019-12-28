import 'package:cloud_firestore/cloud_firestore.dart';

class Commission {
  final double amount;
  final String currency;
  final DateTime createdAt;
  final int shopId;
  final String status;
  final String reason;
  final CommissionProgram program;

  Commission({
    this.amount,
    this.currency,
    this.createdAt,
    this.shopId,
    this.status,
    this.reason,
    this.program,
  });

  factory Commission.fromJson(dynamic json) => Commission(
        amount: double.parse(json['amount'].toString()),
        currency: json['currency'] ?? 'RON',
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        shopId: json['shopId'],
        status: json['status'],
        reason: json['reason'] ?? null,
        program: CommissionProgram.fromJson(json['program']),
      );
}

enum CommissionStatus {
  pending,
  accepted,
  paid,
  rejected,
}

class CommissionProgram {
  final String name;
  final String logo;
  final String status;

  CommissionProgram({this.name, this.logo, this.status});

  factory CommissionProgram.fromJson(dynamic json) => CommissionProgram(
        logo: json != null ? json['logo'] : null,
        name: json != null ? json['name'] : null,
        status: json != null ? json['status'] : null,
      );
}

CommissionStatus parseCommissionStatus(String commissionStatus) =>
    CommissionStatus.values.firstWhere(
        (cS) => cS.toString() == 'CommissionStatus.' + commissionStatus);
