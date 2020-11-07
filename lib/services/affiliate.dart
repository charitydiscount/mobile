import 'dart:io';
import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/util/url.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AffiliateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _baseUrl;

  Future<List<Promotion>> getPromotions({
    String affiliateUniqueCode,
    String programId,
    String programUniqueCode,
  }) =>
      _db.collection('promotions').doc(programId).get().then((snap) => snap.exists
          ? _promotionsFromSnapData(
              snap.data(),
              affiliateUniqueCode,
              programUniqueCode,
              _auth.currentUser,
            )
          : []);

  List<Promotion> _promotionsFromSnapData(
    Map<String, dynamic> snapData,
    String affiliateUniqueCode,
    String programUniqueCode,
    User user,
  ) =>
      snapData.entries
          .map((snapEntry) => _promotionFromSnap(
                snapEntry,
                programUniqueCode,
                user,
                affiliateUniqueCode,
              ))
          .where((promotion) =>
              promotion.promotionStart.isBefore(DateTime.now()) && promotion.promotionEnd.isAfter(DateTime.now()))
          .toList();

  Promotion _promotionFromSnap(
      MapEntry<String, dynamic> snapEntry, String programUniqueCode, User user, String affiliateUniqueCode) {
    final promotion = Promotion.fromJson(Map<String, dynamic>.from(snapEntry.value));
    if (promotion.affiliateUrl != null) {
      promotion.actualAffiliateUrl = interpolateUserCode(
        promotion.affiliateUrl,
        programUniqueCode,
        user.uid,
      );
    } else {
      // Fallback to previous strategy for old promotions
      promotion.actualAffiliateUrl = convertAffiliateUrl(
        promotion.source,
        promotion.landingPageLink,
        affiliateUniqueCode,
        programUniqueCode,
        user.uid,
      );
    }
    return promotion;
  }

  Future<void> launchWebApp(String route, String itemKey, String itemValue) async {
    if (_baseUrl == null) {
      await _setBaseUrl();
    }

    return locator<AuthService>().currentUser.getIdToken().then((idToken) {
      return launchURL(
        '$_baseUrl/auth/$route?access_token=$idToken&itemKey=$itemKey&itemValue=$itemValue',
      );
    });
  }

  Future<void> _setBaseUrl() async {
    _baseUrl = await remoteConfig.getAffiliateEndpoint();
  }

  Future<void> saveClickInfo(String programId) async {
    try {
      final ipifyResponse = await http.get('https://api64.ipify.org');
      await _db.collection('clicks').add({
        'ipAddress': ipifyResponse.body,
        'ipv6Address': ipifyResponse.body,
        'userId': _auth.currentUser.uid,
        'programId': programId,
        'createdAt': FieldValue.serverTimestamp(),
        'deviceType': Platform.operatingSystem,
      });
    } catch (e) {
      stderr.write('Failed to save the IP address: $e');
    }
  }

  Future<List<Promotion>> getAllPromotions() => _db.collection('promotions').doc('all').get().then((snap) {
        if (!snap.exists) {
          return [];
        }

        List<dynamic> promotionsJson = [];
        snap.data().entries.forEach((e) => promotionsJson.addAll(e.value));

        return promotionsJson
            .map((e) => Promotion.fromJson(e))
            .where((promotion) =>
                promotion.promotionStart.isBefore(DateTime.now()) && promotion.promotionEnd.isAfter(DateTime.now()))
            .toList();
      });
}
