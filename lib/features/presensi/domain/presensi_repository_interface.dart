abstract class PresensiRepositoryInterface {
  Future<Map<String, dynamic>> submitPresensi(double lat, double long, String status);
}
