import 'package:cloud_firestore/cloud_firestore.dart';

class Commission {
  final double amount;
  final String currency;
  final DateTime createdAt;
  final int shopId;
  final String status;
  final String reason;

  Commission({
    this.amount,
    this.currency,
    this.createdAt,
    this.shopId,
    this.status,
    this.reason,
  });

  factory Commission.fromJson(dynamic json) => Commission(
        amount: double.parse(json['amount'].toString()),
        currency: json['currency'] ?? 'RON',
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        shopId: json['shopId'],
        status: json['status'],
        reason: json['reason'] ?? null,
      );
}

enum CommissionStatus {
  pending,
  accepted,
  paid,
  rejected,
}

CommissionStatus parseCommissionStatus(String commissionStatus) =>
    CommissionStatus.values.firstWhere(
        (cS) => cS.toString() == 'CommissionStatus.' + commissionStatus);
