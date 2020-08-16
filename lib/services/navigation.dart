import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  List<String> _routes = [];

  String get currentRoute => _routes.last;

  Future<dynamic> navigateTo(
    String routeName, {
    Object arguments,
    bool replace = false,
  }) {
    if (replace) {
      _routes = [routeName];
    } else {
      _routes.add(routeName);
    }
    return replace
        ? navigatorKey.currentState.pushNamedAndRemoveUntil(
            routeName,
            (r) => false,
          )
        : navigatorKey.currentState.pushNamed(
            routeName,
            arguments: arguments,
          );
  }

  void goBack([dynamic result]) {
    _routes.removeLast();
    return navigatorKey.currentState.pop(result);
  }
}
