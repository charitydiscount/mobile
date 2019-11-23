import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
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
