abstract class PresensiRepository {
  Future<void> submitPresensi({
    required String type,
    required double latitude,
    required double longitude,
  });
}
