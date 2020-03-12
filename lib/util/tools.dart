import 'package:intl/intl.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String formatDate(DateTime date) => DateFormat.yMd('ro_RO').format(date);
String formatDateTime(DateTime date) =>
    DateFormat.yMd('ro_RO').add_jm().format(date);

String removeAllHtmlTags(String htmlText) {
  RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

  return htmlText.replaceAll(exp, '');
}
