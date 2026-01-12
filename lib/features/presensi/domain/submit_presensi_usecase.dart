import '../data/presensi_repository.dart';

class SubmitPresensiUseCase {
  final PresensiRepository repository;

  SubmitPresensiUseCase(this.repository);

  Future<void> execute({
    required String type,
    required double latitude,
    required double longitude,
  }) async {
    await repository.submitPresensi(
      type: type,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
