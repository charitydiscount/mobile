import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String formatDate(DateTime date) => DateFormat.yMd('ro_RO').format(date);
String formatDateTime(DateTime date) =>
    DateFormat.yMd('ro_RO').add_jm().format(date);

String removeAllHtmlTags(String htmlText) {
  RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

  return htmlText.replaceAll(exp, '');
}

DateTime jsonToDate(dynamic json) => json != null
    ? (json is Timestamp ? json.toDate() : DateTime.parse(json))
    : null;
