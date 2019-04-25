import 'package:flutter/services.dart';

String getExceptionText(Exception e) {
  if (e is PlatformException) {
    switch (e.message) {
      case 'There is no user record corresponding to this identifier. The user may have been deleted.':
        return 'User with this email address not found.';
        break;
      case 'The password is invalid or the user does not have a password.':
        return 'Wrong credentials';
        break;
      case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
        return 'No internet connection.';
        break;
      case 'The email address is already in use by another account.':
        return 'This email address already has an account.';
        break;
      default:
        return 'Unknown error occured.';
    }
  } else {
    return 'Unknown error occured.';
  }
}
