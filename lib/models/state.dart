import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/settings.dart';
import 'package:charity_discount/models/market.dart';

class StateModel {
  bool isLoading;
  User user;
  Settings settings = Settings(lang: 'ro');
  Market market;

  StateModel({this.isLoading = false, this.user, this.settings, this.market});
}
