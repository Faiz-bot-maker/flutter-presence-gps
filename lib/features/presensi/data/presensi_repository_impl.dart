import 'dart:convert';
import 'package:http/http.dart' as http;
import 'presensi_repository.dart';

class PresensiRepositoryImpl implements PresensiRepository {
  // GANTI sesuai backend kamu
  static const String _baseUrl = 'http://10.0.2.2:5000';

  @override
  Future<void> submitPresensi({
    required String type,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$_baseUrl/attendance');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type, // MASUK / KELUAR
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Gagal presensi (${response.statusCode}): ${response.body}',
      );
    }
  }
}
