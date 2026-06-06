import '../models/queue_entry_model.dart';
import 'api_client.dart';

class QueueEntryService {
  Future<List<QueueEntryModel>> getMyQueueEntries() async {
    final response = await ApiClient.get('/queue-entries/my');

    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (item) => QueueEntryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<QueueEntryModel?> createQueueEntry({
    required int studyTableId,
  }) async {
    final response = await ApiClient.post(
      '/queue-entries',
      body: {
        'studyTableId': studyTableId,
      },
    );

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return QueueEntryModel.fromJson(data);
    }

    if (data is Map) {
      return QueueEntryModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    return null;
  }

  Future<List<QueueEntryModel>> getAllQueueEntries() async {
    final response = await ApiClient.get('/queue-entries');

    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (item) => QueueEntryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<QueueEntryModel?> updateQueueEntryStatus({
    required int queueEntryId,
    required int status,
  }) async {
    final response = await ApiClient.put(
      '/queue-entries/$queueEntryId/status',
      body: {
        'status': status,
      },
    );

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return QueueEntryModel.fromJson(data);
    }

    if (data is Map) {
      return QueueEntryModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    return null;
  }
}