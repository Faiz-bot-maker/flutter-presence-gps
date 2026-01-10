abstract class PresensiRepositoryInterface {
  Future<Map<String, dynamic>> submitPresensi(double lat, double long, String status);
  Future<Map<String, dynamic>> checkIn(double lat, double long, String employeeId);
  Future<Map<String, dynamic>> checkOut(double lat, double long, String employeeId);
  Future<Map<String, dynamic>> getTodayAttendance(String employeeId);
}
