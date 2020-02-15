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
