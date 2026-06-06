import '../models/issue_report_model.dart';
import 'api_client.dart';

class IssueReportService {
  Future<List<IssueReportModel>> getMyIssueReports() async {
    final response = await ApiClient.get('/issue-reports/my');

    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (item) => IssueReportModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<List<IssueReportModel>> getAllIssueReports() async {
    final response = await ApiClient.get('/issue-reports');

    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (item) => IssueReportModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<IssueReportModel?> createIssueReport({
    required int studyTableId,
    required String description,
  }) async {
    final response = await ApiClient.post(
      '/issue-reports',
      body: {
        'studyTableId': studyTableId,
        'description': description,
      },
    );

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return IssueReportModel.fromJson(data);
    }

    if (data is Map) {
      return IssueReportModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    return null;
  }

  Future<IssueReportModel?> updateIssueReportStatus({
    required int issueReportId,
    required int status,
  }) async {
    final response = await ApiClient.put(
      '/issue-reports/$issueReportId/status',
      body: {
        'status': status,
      },
    );

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return IssueReportModel.fromJson(data);
    }

    if (data is Map) {
      return IssueReportModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    return null;
  }

  Future<void> updateIssueStatus({
    required int issueReportId,
    required int status,
  }) async {
    await ApiClient.put(
      '/issue-reports/$issueReportId/status',
      body: {
        'status': status,
      },
    );
  }
}