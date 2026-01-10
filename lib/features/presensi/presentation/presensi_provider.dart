import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/constants.dart';
import '../domain/submit_presensi_usecase.dart';

class PresensiProvider extends ChangeNotifier {
  final SubmitPresensiUseCase submitPresensiUseCase;

  PresensiProvider({required this.submitPresensiUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _message = '';
  String get message => _message;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  bool _isInOfficeRadius = false;
  bool get isInOfficeRadius => _isInOfficeRadius;
  
  bool _hasCheckedIn = false;
  bool get hasCheckedIn => _hasCheckedIn;

  double _distanceToOffice = 0.0;
  double get distanceToOffice => _distanceToOffice;

  StreamSubscription<Position>? _positionSubscription;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _message = 'Mengambil lokasi...';
    notifyListeners();

    try {
      final ok = await _ensureLocationAccess();
      if (!ok) return;

      _currentPosition = await Geolocator.getCurrentPosition();
      _updateFromPosition(_currentPosition!);
    } catch (e) {
      _message = 'Gagal mengambil lokasi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startLocationUpdates() async {
    if (_positionSubscription != null) return;

    final ok = await _ensureLocationAccess();
    if (!ok) return;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    _positionSubscription = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        _currentPosition = pos;
        _updateFromPosition(pos);
        notifyListeners();
      },
      onError: (e) {
        _message = 'Gagal update lokasi: $e';
        notifyListeners();
      },
    );
  }

  void _updateFromPosition(Position pos) {
    _distanceToOffice = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      Constants.officeLatitude,
      Constants.officeLongitude,
    );

    _isInOfficeRadius = _distanceToOffice <= Constants.maxDistanceInMeters;

    if (_isInOfficeRadius) {
      _message = 'Di dalam radius kantor (${_distanceToOffice.toStringAsFixed(1)}m)';
    } else {
      _message = 'Di luar radius kantor (${_distanceToOffice.toStringAsFixed(1)}m)';
    }
  }

  Future<bool> _ensureLocationAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _message = 'Layanan lokasi tidak aktif.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _message = 'Izin lokasi ditolak.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _message = 'Izin lokasi ditolak permanen.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> submitPresensi(String type) async {
    if (_currentPosition == null) {
      _message = 'Lokasi belum ditemukan.';
      notifyListeners();
      return;
    }

    if (!_isInOfficeRadius) {
      _message = 'Gagal: Anda di luar radius kantor.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final result = await submitPresensiUseCase.execute(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      type,
    );

    _isLoading = false;
    _message = result['message'];
    
    if (result['success'] == true && type == 'MASUK') {
      _hasCheckedIn = true;
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    super.dispose();
  }
}
