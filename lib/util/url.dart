import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

String convertAffiliateUrl(String url, String affiliateCode, String uniqueId) {
  //"https://" + t.host + "/events/click?ad_type=quicklink&aff_code="
  // + t.affiliate_code + "&unique=" + t.campaigns[i].unique_code
  // + "&redirect_to=" + encodeURIComponent(o)
  final baseUrl =
      'https://event.2performant.com/events/click?ad_type=quicklink';
  final affCode = 'aff_code=$affiliateCode';
  final unique = 'unique=$uniqueId';
  final redirect = 'redirect_to=$url';

  return '$baseUrl&$affCode&$unique&$redirect';
}
