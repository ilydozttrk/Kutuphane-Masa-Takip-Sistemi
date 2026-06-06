import 'package:flutter/material.dart';

import '../models/issue_report_model.dart';
import '../services/issue_report_service.dart';

class AdminIssueReportsScreen extends StatefulWidget {
  const AdminIssueReportsScreen({super.key});

  @override
  State<AdminIssueReportsScreen> createState() =>
      _AdminIssueReportsScreenState();
}

class _AdminIssueReportsScreenState extends State<AdminIssueReportsScreen> {
  final IssueReportService _issueReportService = IssueReportService();

  List<IssueReportModel> reports = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      final result = await _issueReportService.getAllIssueReports();

      setState(() {
        reports = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("ISSUE HATASI: $e");
    }
  }

  Color getStatusColor(IssueReportModel report) {
    if (report.isOpen) {
      return Colors.orange;
    }

    if (report.isInProgress) {
      return Colors.blue;
    }

    if (report.isResolved) {
      return Colors.green;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sorun Bildirimleri")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: getStatusColor(report),
                              child: const Icon(
                                Icons.report_problem,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                report.userFullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text("Masa: ${report.studyTableCode}"),
                        const SizedBox(height: 6),
                        DropdownButton<int>(
                          value: report.status,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text("Açık")),
                            DropdownMenuItem(
                              value: 2,
                              child: Text("İnceleniyor"),
                            ),
                            DropdownMenuItem(value: 3, child: Text("Çözüldü")),
                            DropdownMenuItem(
                              value: 4,
                              child: Text("Reddedildi"),
                            ),
                          ],
                          onChanged: (value) async {
                            if (value == null) return;

                            try {
                              await _issueReportService.updateIssueStatus(
                                issueReportId: report.id,
                                status: value,
                              );

                              loadReports();

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Durum güncellendi."),
                                ),
                              );
                            } catch (e) {
                              debugPrint("STATUS HATASI: $e");
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(report.description),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
