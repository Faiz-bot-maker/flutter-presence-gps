class Constants {
  // API Base URL
  static const String baseUrl = 'https://python-flask-api-presence-production-5b44.up.railway.app/';
  // static const String baseUrl = 'http://10.0.2.2:5000'; // Localhost for Android Emulator
  // Use 'http://127.0.0.1:5000' for Windows/Web/iOS Simulator
  
  // Endpoints
  static const String presensiEndpoint = '$baseUrl/attendance'; // Mapped to Check-in (Legacy)
  static const String checkInEndpoint = '$baseUrl/attendance/checkin';
  static const String checkOutEndpoint = '$baseUrl/attendance/checkout';
  static const String loginEndpoint = '$baseUrl/login';

  static String todayAttendanceEndpoint(String employeeId) => '$baseUrl/attendance/today/$employeeId';
  
  // Coordinates for PT. Glosindo
  static const double officeLatitude = -6.616484; 
  static const double officeLongitude = 106.715732;
  
  // Maximum allowed distance in meters
  static const double maxDistanceInMeters = 100.0;
}
