import '../models/block_record_model.dart';
import 'api_client.dart';

class BlockRecordService {
  Future<List<BlockRecordModel>> getAllBlockRecords() async {
    final response = await ApiClient.get('/block-records');

    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (item) =>
                BlockRecordModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    return [];
  }

  Future<void> createBlockRecord({
    required int userId,
    required String reason,
    String? endsAt,
  }) async {
    await ApiClient.post(
      '/block-records',
      body: {'userId': userId, 'reason': reason, 'endsAt': endsAt},
    );
  }

  Future<void> removeBlock({required int blockRecordId}) async {
    await ApiClient.put('/block-records/$blockRecordId/remove');
  }
}
