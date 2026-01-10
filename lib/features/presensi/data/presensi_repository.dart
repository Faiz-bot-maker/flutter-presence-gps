import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/utils/constants.dart';
import '../domain/presensi_repository_interface.dart';

class PresensiRepositoryImpl implements PresensiRepositoryInterface {
  @override
  Future<Map<String, dynamic>> submitPresensi(double lat, double long, String status) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.dummyApiUrl),
        body: jsonEncode({
          'latitude': lat,
          'longitude': long,
          'status': status,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Presensi Berhasil'};
      } else {
        return {'success': false, 'message': 'Gagal: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
