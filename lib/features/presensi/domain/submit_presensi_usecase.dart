import 'presensi_repository_interface.dart';

class SubmitPresensiUseCase {
  final PresensiRepositoryInterface repository;

  SubmitPresensiUseCase(this.repository);

  Future<Map<String, dynamic>> execute(double lat, double long, String status) {
    return repository.submitPresensi(lat, long, status);
  }
}
