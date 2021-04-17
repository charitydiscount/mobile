import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/ui/wallet/pass_code.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

LocalAuthentication _localAuthentication = LocalAuthentication();

Future<bool> authorize({
  @required String title,
  @required BuildContext context,
  @required CharityService charityService,
}) async {
  final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;

  return canCheckBiometrics == true
      ? _localAuthentication.authenticate(
          localizedReason: title,
          biometricOnly: true,
          stickyAuth: true,
        )
      : Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                Otp(charityService: charityService),
            settings: RouteSettings(name: 'Authorize'),
          ),
        );
}
