import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iban_form_field/iban_form_field.dart';

User userFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromJson(jsonData);
}

String userToJson(User data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class User {
  String userId;
  String firstName;
  String lastName;
  String email;
  String photoUrl;
  List<SavedAccount> savedAccounts = [];

  User({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.photoUrl,
    this.savedAccounts,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        photoUrl: json['photoUrl'],
        savedAccounts: List<SavedAccount>.from(
          (json['accounts'] ?? [])
              .map((accountJson) => SavedAccount.fromJson(accountJson))
              .toList(),
        ),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'photoUrl': photoUrl
      };

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }
}

class SavedAccount {
  final String name;
  final String iban;
  final String alias;

  SavedAccount({
    @required this.name,
    @required this.iban,
    this.alias,
  });

  factory SavedAccount.fromIban(
    Iban iban,
    String name,
    String nickname,
  ) {
    return SavedAccount(
      iban: iban.electronicFormat,
      name: name,
      alias: nickname,
    );
  }

  factory SavedAccount.fromJson(dynamic json) => SavedAccount(
        iban: json['iban'],
        name: json['name'],
        alias: json['nickname'] ?? '',
      );

  Iban get fullIban {
    Iban fullIban = Iban(iban.substring(0, 2));
    fullIban.checkDigits = iban.substring(2, 4);
    fullIban.basicBankAccountNumber = iban.substring(4);

    return fullIban;
  }

  Map<String, dynamic> toJson() => {
        'iban': iban,
        'name': name,
        'nickname': alias,
      };
}
