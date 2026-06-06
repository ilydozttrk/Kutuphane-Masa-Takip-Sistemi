import 'package:flutter/material.dart';
import 'admin_queue_entries_screen.dart';
import '../models/study_table_model.dart';
import '../services/study_table_service.dart';
import 'admin_issue_reports_screen.dart';
import 'admin_tables_screen.dart';
import 'admin_qr_codes_screen.dart';
import 'admin_location_areas_screen.dart';
import '../models/issue_report_model.dart';
import '../models/queue_entry_model.dart';

import '../services/issue_report_service.dart';
import '../services/queue_entry_service.dart';
import 'admin_block_records_screen.dart';
import 'admin_notifications_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String fullName;
  final String role;

  const AdminDashboardScreen({
    super.key,
    required this.fullName,
    required this.role,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final StudyTableService _studyTableService = StudyTableService();
  final IssueReportService _issueReportService = IssueReportService();

  final QueueEntryService _queueEntryService = QueueEntryService();

  List<IssueReportModel> issueReports = [];

  List<QueueEntryModel> queueEntries = [];

  List<StudyTableModel> tables = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      final tablesResult = await _studyTableService.getStudyTables();

      final issueResult = await _issueReportService.getAllIssueReports();

      final queueResult = await _queueEntryService.getAllQueueEntries();

      setState(() {
        tables = tablesResult;
        issueReports = issueResult;
        queueEntries = queueResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("DASHBOARD HATASI: $e");
    }
  }

  Future<void> loadTables() async {
    try {
      final result = await _studyTableService.getStudyTables();

      setState(() {
        tables = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("MASA HATASI: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(fullName: widget.fullName, role: widget.role),

              const SizedBox(height: 20),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _DashboardCard(
                        title: "Masalar",
                        value: tables.length.toString(),
                        icon: Icons.event_seat,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _DashboardCard(
                        title: "Sorun Bildirimi",
                        value: issueReports.length.toString(),
                        icon: Icons.report_problem,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _DashboardCard(
                        title: "Sıra",
                        value: queueEntries.length.toString(),
                        icon: Icons.people,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _DashboardCard(
                        title: "Boş Masa",
                        value: tables
                            .where((table) => table.isAvailable)
                            .length
                            .toString(),
                        icon: Icons.check_circle,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminTablesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.table_rows),
                    label: const Text(
                      "Masaları Gör",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminIssueReportsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.report_problem),
                    label: const Text(
                      "Sorun Bildirimlerini Gör",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminQueueEntriesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: const Text(
                      "Sıra Yönetimi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminQrCodesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text(
                      "QR Yönetimi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminLocationAreasScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text(
                      "Alan Yönetimi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminBlockRecordsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.block),
                    label: const Text(
                      "Bloklama Yönetimi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminNotificationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                    label: const Text(
                      "Bildirimlerim",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String fullName;
  final String role;

  const _HeaderCard({required this.fullName, required this.role});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFF1E3A8A),
              child: Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hoş geldin $fullName",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Rol: $role",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Column(
          children: [
            Icon(icon, size: 34, color: const Color(0xFF1E3A8A)),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
