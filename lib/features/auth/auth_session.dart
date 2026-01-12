import 'package:flutter/foundation.dart';

class UserModel {
  final String username;
  final String name;
  final String role;
  final String shift;
  final String jamMasuk;
  final String jamPulang;
  final String profileImage;
  final String email;
  final String nik;

  UserModel({
    required this.username,
    required this.name,
    required this.role,
    required this.shift,
    required this.jamMasuk,
    required this.jamPulang,
    required this.profileImage,
    required this.email,
    required this.nik,
  });
}

class AuthSession extends ChangeNotifier {
  bool _isLoggedIn = false;
  UserModel? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;

  final List<UserModel> _dummyUsers = [
    UserModel(
      username: 'faiz',
      name: 'Muhammad Faiz Fathurahman',
      role: 'Mobile Developer',
      shift: 'Shift Pagi',
      jamMasuk: '08:00 WIB',
      jamPulang: '17:00 WIB',
      profileImage: 'https://i.pravatar.cc/150?img=11',
      email: 'faiz.dev@glosindo.com',
      nik: '1234567890',
    ),
    UserModel(
      username: 'haikal',
      name: 'Haikal Azka',
      role: 'Backend Engineer',
      shift: 'Shift Siang',
      jamMasuk: '13:00 WIB',
      jamPulang: '22:00 WIB',
      profileImage: 'https://i.pravatar.cc/150?img=33',
      email: 'haikal.azka@glosindo.com',
      nik: '1234567891',
    ),
    UserModel(
      username: 'rehan',
      name: 'Rehan Saputra',
      role: 'DevOps Engineer',
      shift: 'Shift Malam',
      jamMasuk: '21:00 WIB',
      jamPulang: '06:00 WIB',
      profileImage: 'https://i.pravatar.cc/150?img=59',
      email: 'rehan.saputra@glosindo.com',
      nik: '1234567892',
    ),
  ];

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    // Simple dummy login logic
    if (password == '12345') {
      try {
        final user = _dummyUsers.firstWhere((u) => u.username == username);
        _currentUser = user;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}
