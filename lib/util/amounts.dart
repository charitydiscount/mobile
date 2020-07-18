import 'dart:math';

class AmountHelper {
  static String amountToString(double amount, {int places = 2}) {
    return _dp(amount, places).toStringAsFixed(places);
  }

  static double _dp(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).floor().toDouble() / mod);
  }
}
