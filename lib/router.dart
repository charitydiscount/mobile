import 'package:charity_discount/ui/programs/shop_details.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/util/constants.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.shopDetails:
        return MaterialPageRoute(
          builder: (_) => ShopDetails(program: settings.arguments),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => UndefinedView(
            name: settings.name,
          ),
        );
    }
  }
}

class UndefinedView extends StatelessWidget {
  final String name;
  const UndefinedView({Key key, this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Route for $name is not defined'),
      ),
    );
  }
}
