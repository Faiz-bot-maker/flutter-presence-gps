import 'package:flutter/foundation.dart';

class AuthSession extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login({required String username, required String password}) async {
    _isLoggedIn = true;
    notifyListeners();
  }
}

