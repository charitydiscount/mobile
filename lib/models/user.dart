import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:iban_form_field/iban_form_field.dart';

String userToJson(User data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class User {
  String userId;
  String name;
  String email;
  String photoUrl;
  List<SavedAccount> savedAccounts;

  User({
    this.userId,
    this.name,
    this.email,
    this.photoUrl,
  });

  factory User.fromFirebaseAuth(auth.User user) => User(
        email: user.email,
        name: user.displayName,
        userId: user.uid,
        photoUrl: user.photoURL,
      );

  factory User.fromJson(Map<String, dynamic> userJson) => User(
        email: userJson['email'],
        name: userJson['name'],
        userId: userJson['uid'],
        photoUrl: userJson['photoUrl'],
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
      };
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
