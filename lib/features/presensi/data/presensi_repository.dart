import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/utils/constants.dart';
import '../domain/presensi_repository_interface.dart';

class PresensiRepositoryImpl implements PresensiRepositoryInterface {
  @override
  Future<Map<String, dynamic>> submitPresensi(double lat, double long, String status) async {
    // Handle status logic
    if (status == 'MASUK') {
      return checkIn(lat, long, 'unknown_employee');
    } else if (status == 'KELUAR') {
      return checkOut(lat, long, 'unknown_employee');
    }
    return {'success': false, 'message': 'Status tidak valid'};
  }

  @override
  Future<Map<String, dynamic>> checkIn(double lat, double long, String employeeId) async {
    return _submitData(Constants.checkInEndpoint, lat, long, 'Masuk', employeeId);
  }

  @override
  Future<Map<String, dynamic>> checkOut(double lat, double long, String employeeId) async {
    return _submitData(Constants.checkOutEndpoint, lat, long, 'Pulang', employeeId);
  }

  @override
  Future<Map<String, dynamic>> getTodayAttendance(String employeeId) async {
    try {
      final response = await http.get(
        Uri.parse(Constants.todayAttendanceEndpoint(employeeId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Gagal mengambil data: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi Gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> _submitData(String url, double lat, double long, String status, [String? employeeId]) async {
    try {
      final body = {
        'latitude': lat,
        'longitude': long,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      if (employeeId != null) {
        body['employee_id'] = employeeId;
      }

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': '$status Berhasil'};
      } else {
        return {'success': false, 'message': 'Gagal: ${response.statusCode} ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi Gagal: $e'};
    }
  }
}
