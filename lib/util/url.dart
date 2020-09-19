import 'dart:io';
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/services/analytics.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/ui/tutorial/access_explanation.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String url, {Map<String, String> headers}) async {
  if (await canLaunch(url)) {
    await launch(url, headers: headers, forceSafariVC: false);
  } else {
    throw 'Could not launch $url';
  }
}

String convertAffiliateUrl(
  String url,
  String affiliateCode,
  String uniqueId,
  String userId,
) {
  final baseUrl =
      'https://event.2performant.com/events/click?ad_type=quicklink';
  final affCode = 'aff_code=$affiliateCode';
  final unique = 'unique=$uniqueId';
  final redirect = 'redirect_to=$url';
  final tag = 'st=$userId';

  return '$baseUrl&$affCode&$unique&$redirect&$tag';
}

const USER_LINK_PLACEHOLDER = '{userId}';
const PROGRAM_LINK_PLACEHOLDER = '{programUniqueCode}';

String interpolateUserCode(
  String affiliateUrl,
  String programUniqueCode,
  String userId,
) {
  return affiliateUrl
      .replaceAll(PROGRAM_LINK_PLACEHOLDER, programUniqueCode)
      .replaceAll(USER_LINK_PLACEHOLDER, userId);
}

void openAffiliateLink(
  String url,
  BuildContext context,
  String programId,
  String programName,
  String eventScreen,
) async {
  if (!locator<AuthService>().isActualUser()) {
    showSignInDialog(context);
    return;
  }

  analytics.logEvent(
    name: 'access_shop',
    parameters: {
      'id': programId,
      'name': programName,
      'screen': eventScreen,
    },
  );

  bool continueToShop = await showExplanationDialog(context);
  if (continueToShop != true) {
    return;
  }

  try {
    await locator<AffiliateService>().saveClickInfo(programId);
  } catch (e) {
    stderr.write(e.toString());
  }

  launchURL(url);
}
