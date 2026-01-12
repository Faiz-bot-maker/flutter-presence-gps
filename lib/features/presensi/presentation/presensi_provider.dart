import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/constants.dart';
import '../domain/submit_presensi_usecase.dart';

class PresensiProvider extends ChangeNotifier {
  final SubmitPresensiUseCase submitPresensiUseCase;

  PresensiProvider({required this.submitPresensiUseCase});

  Position? currentPosition;
  bool isInOfficeRadius = false;
  bool isLoading = false;

  bool hasCheckedIn = false;
  bool hasCheckedOut = false;

  String message = '';

  StreamSubscription<Position>? _positionStream;

  /// ===============================
  /// CEK STATUS HARI INI (DUMMY)
  /// ===============================
  Future<void> checkTodayStatus() async {
    // nanti bisa sambung API
    hasCheckedIn = false;
    hasCheckedOut = false;
    notifyListeners();
  }

  /// ===============================
  /// PERMISSION & LOKASI (AMAN)
  /// ===============================
  Future<void> getCurrentLocation() async {
    try {
      // 1. GPS aktif?
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        message = 'GPS tidak aktif. Aktifkan lokasi.';
        notifyListeners();
        return;
      }

      // 2. Cek permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        message = 'Izin lokasi ditolak';
        notifyListeners();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        message =
            'Izin lokasi ditolak permanen. Aktifkan dari pengaturan aplikasi.';
        notifyListeners();
        return;
      }

      // 3. Ambil lokasi (FOREGROUND ONLY)
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      _checkRadius();
      message = '';
      notifyListeners();
    } catch (e) {
      message = 'Gagal mendapatkan lokasi';
      notifyListeners();
    }
  }

  /// ===============================
  /// UPDATE LOKASI REALTIME (AMAN)
  /// ===============================
  void startLocationUpdates() {
    _positionStream?.cancel();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((position) {
      currentPosition = position;
      _checkRadius();
      notifyListeners();
    });
  }

  /// ===============================
  /// CEK RADIUS KANTOR
  /// ===============================
  void _checkRadius() {
    if (currentPosition == null) {
      isInOfficeRadius = false;
      return;
    }

    final distance = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      Constants.officeLatitude,
      Constants.officeLongitude,
    );

    // 🔥 TOLERANSI GPS ±25M (WAJIB)
    isInOfficeRadius =
        distance <= (Constants.maxDistanceInMeters + 25);
  }

  /// ===============================
  /// SUBMIT PRESENSI
  /// ===============================
  Future<void> submitPresensi(String type) async {
    if (!isInOfficeRadius) {
      message = 'Anda berada di luar radius kantor';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await submitPresensiUseCase.execute(
        type: type,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
      );

      if (type == 'MASUK') {
        hasCheckedIn = true;
        hasCheckedOut = false;
      } else {
        hasCheckedOut = true;
      }

      message = 'Presensi berhasil';
    } catch (e) {
      message = 'Presensi gagal';
    }

    isLoading = false;
    notifyListeners();
  }

  /// ===============================
  /// CLEANUP
  /// ===============================
  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
