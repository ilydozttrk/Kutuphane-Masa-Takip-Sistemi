import '../models/study_table_model.dart';
import 'api_client.dart';

class StudyTableService {
  Future<List<StudyTableModel>> getStudyTables() async {
    final response = await ApiClient.get('/study-tables');

    final data = response['data'];

    if (data is List) {
      return data
          .map((item) => StudyTableModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<void> updateStudyTableStatus({
    required int studyTableId,
    required int status,
  }) async {
    await ApiClient.put(
      '/study-tables/$studyTableId/status',
      body: {'status': status},
    );
  }

  Future<void> createStudyTable({
    required String code,
    required int locationAreaId,
  }) async {
    await ApiClient.post(
      '/study-tables',
      body: {'code': code, 'locationAreaId': locationAreaId},
    );
  }
}
