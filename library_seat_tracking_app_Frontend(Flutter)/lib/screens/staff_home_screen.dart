import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_notification_model.dart';
import '../models/issue_report_model.dart';
import '../models/location_area_model.dart';
import '../models/qr_code_record_model.dart';
import '../models/queue_entry_model.dart';
import '../models/study_table_model.dart';
import '../services/api_client.dart';
import '../services/app_notification_service.dart';
import '../services/auth_service.dart';
import '../services/issue_report_service.dart';
import '../services/location_area_service.dart';
import '../services/qr_code_record_service.dart';
import '../services/queue_entry_service.dart';
import '../services/study_table_service.dart';
import 'login_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  final String fullName;
  final String role;

  const StaffHomeScreen({
    super.key,
    required this.fullName,
    required this.role,
  });

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  final StudyTableService _studyTableService = StudyTableService();
  final IssueReportService _issueReportService = IssueReportService();
  final QueueEntryService _queueEntryService = QueueEntryService();
  final QrCodeRecordService _qrCodeRecordService = QrCodeRecordService();
  final LocationAreaService _locationAreaService = LocationAreaService();
  final AppNotificationService _appNotificationService =
      AppNotificationService();

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedSection = 'tables';

  List<StudyTableModel> _tables = [];
  List<IssueReportModel> _issueReports = [];
  List<QueueEntryModel> _queueEntries = [];
  List<QrCodeRecordModel> _qrCodeRecords = [];
  List<LocationAreaModel> _locationAreas = [];
  List<AppNotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadStaffPanelData();
  }

  Future<void> _loadStaffPanelData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _studyTableService.getStudyTables(),
        _issueReportService.getAllIssueReports(),
        _queueEntryService.getAllQueueEntries(),
        _qrCodeRecordService.getQrCodeRecords(),
        _locationAreaService.getLocationAreas(),
        _appNotificationService.getMyNotifications(),
      ]);

      if (!mounted) return;

      setState(() {
        _tables = results[0] as List<StudyTableModel>;
        _issueReports = results[1] as List<IssueReportModel>;
        _queueEntries = results[2] as List<QueueEntryModel>;
        _qrCodeRecords = results[3] as List<QrCodeRecordModel>;
        _locationAreas = results[4] as List<LocationAreaModel>;
        _notifications = results[5] as List<AppNotificationModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final authService = AuthService();
    await authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _updateIssueStatus({
    required IssueReportModel issueReport,
    required int status,
  }) async {
    try {
      await _issueReportService.updateIssueReportStatus(
        issueReportId: issueReport.id,
        status: status,
      );

      if (!mounted) return;

      _showMessage('Sorun bildirimi durumu güncellendi.');
      await _loadStaffPanelData();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Durum güncellenemedi: $e');
    }
  }

  Future<void> _updateQueueStatus({
    required QueueEntryModel queueEntry,
    required int status,
  }) async {
    try {
      await _queueEntryService.updateQueueEntryStatus(
        queueEntryId: queueEntry.id,
        status: status,
      );

      if (!mounted) return;

      _showMessage('Sıra kaydı durumu güncellendi.');
      await _loadStaffPanelData();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Durum güncellenemedi: $e');
    }
  }

  Future<void> _updateQrCodeStatus({
    required QrCodeRecordModel qrCodeRecord,
    required bool isActive,
  }) async {
    try {
      await _qrCodeRecordService.updateQrCodeRecordStatus(
        qrCodeRecordId: qrCodeRecord.id,
        isActive: isActive,
      );

      if (!mounted) return;

      _showMessage(
        isActive ? 'QR kaydı aktif yapıldı.' : 'QR kaydı pasif yapıldı.',
      );

      await _loadStaffPanelData();
    } catch (e) {
      if (!mounted) return;
      _showMessage('QR durumu güncellenemedi: $e');
    }
  }

  Future<void> _markNotificationAsRead(
    AppNotificationModel notification,
  ) async {
    if (notification.isRead) {
      return;
    }

    try {
      await _appNotificationService.markAsRead(
        notificationId: notification.id,
      );

      if (!mounted) return;

      await _loadStaffPanelData();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Bildirim okundu yapılamadı: $e');
    }
  }

  Future<void> _showQrCodeImage(QrCodeRecordModel qrCodeRecord) async {
    try {
      final bytes = await _qrCodeRecordService.getQrCodeImageBytes(
        qrCodeRecordId: qrCodeRecord.id,
      );

      if (!mounted) return;

      _showQrImageDialog(
        title: 'QR Görseli',
        qrCodeRecord: qrCodeRecord,
        bytes: bytes,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('QR görseli alınamadı: $e');
    }
  }

  Future<void> _showQrDownloadPreview(QrCodeRecordModel qrCodeRecord) async {
    try {
      final bytes = await _qrCodeRecordService.downloadQrCodeBytes(
        qrCodeRecordId: qrCodeRecord.id,
      );

      if (!mounted) return;

      _showQrImageDialog(
        title: 'QR İndirme Önizlemesi',
        qrCodeRecord: qrCodeRecord,
        bytes: bytes,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('QR indirme verisi alınamadı: $e');
    }
  }

  Future<void> _showQrPrintHtml(QrCodeRecordModel qrCodeRecord) async {
    try {
      final html = await _qrCodeRecordService.getQrCodePrintHtml(
        qrCodeRecordId: qrCodeRecord.id,
      );

      if (!mounted) return;

      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('Yazdırma HTML - ${qrCodeRecord.code}'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: SelectableText(
                  html,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: html));
                  Navigator.pop(dialogContext);
                  _showMessage('Yazdırma HTML içeriği kopyalandı.');
                },
                child: const Text('HTML Kopyala'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Kapat'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Yazdırma HTML içeriği alınamadı: $e');
    }
  }

  Future<void> _copyQrEndpointLink({
    required QrCodeRecordModel qrCodeRecord,
    required String endpointType,
  }) async {
    final endpoint = endpointType == 'download'
        ? '/qr-code-records/${qrCodeRecord.id}/download'
        : '/qr-code-records/${qrCodeRecord.id}/print';

    final url = ApiClient.buildUrl(endpoint);

    await Clipboard.setData(
      ClipboardData(text: url),
    );

    if (!mounted) return;

    _showMessage(
      endpointType == 'download'
          ? 'QR indirme bağlantısı kopyalandı.'
          : 'QR yazdırma bağlantısı kopyalandı.',
    );
  }

  void _showQrImageDialog({
    required String title,
    required QrCodeRecordModel qrCodeRecord,
    required Uint8List bytes,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$title - ${qrCodeRecord.code}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  'Masa: ${qrCodeRecord.studyTableCode.isEmpty ? '-' : qrCodeRecord.studyTableCode}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                SelectableText(
                  'Kod: ${qrCodeRecord.code}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: qrCodeRecord.code),
                );
                Navigator.pop(dialogContext);
                _showMessage('QR kod değeri kopyalandı.');
              },
              child: const Text('Kodu Kopyala'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _selectSection(String section) {
    setState(() {
      _selectedSection = section;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _tableStatusColor(StudyTableModel table) {
    if (table.isAvailable) return const Color(0xFF16A34A);
    if (table.isOccupied) return const Color(0xFFDC2626);
    if (table.isReserved) return const Color(0xFFF59E0B);
    if (table.isMaintenance) return const Color(0xFF6B7280);
    return const Color(0xFF64748B);
  }

  Color _issueStatusColor(IssueReportModel issueReport) {
    if (issueReport.isOpen) return const Color(0xFFDC2626);
    if (issueReport.isInProgress) return const Color(0xFFF59E0B);
    if (issueReport.isResolved) return const Color(0xFF16A34A);
    if (issueReport.isRejected) return const Color(0xFF6B7280);
    return const Color(0xFF64748B);
  }

  Color _queueStatusColor(QueueEntryModel queueEntry) {
    if (queueEntry.isWaiting) return const Color(0xFFF59E0B);
    if (queueEntry.isNotified) return const Color(0xFF2563EB);
    if (queueEntry.isCompleted) return const Color(0xFF16A34A);
    if (queueEntry.isCancelled) return const Color(0xFF6B7280);
    return const Color(0xFF64748B);
  }

  Color _activeStatusColor(bool isActive) {
    return isActive ? const Color(0xFF16A34A) : const Color(0xFF6B7280);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return date.toLocal().toString().split('.').first;
  }

  int get _availableTableCount =>
      _tables.where((table) => table.isAvailable).length;

  int get _occupiedTableCount =>
      _tables.where((table) => table.isOccupied).length;

  int get _openIssueCount =>
      _issueReports.where((issue) => issue.isOpen).length;

  int get _waitingQueueCount =>
      _queueEntries.where((queue) => queue.isWaiting).length;

  int get _activeQrCodeCount =>
      _qrCodeRecords.where((qrCode) => qrCode.isActive).length;

  int get _activeLocationAreaCount =>
      _locationAreas.where((area) => area.isActive).length;

  int get _unreadNotificationCount =>
      _notifications.where((notification) => !notification.isRead).length;

  String get _selectedSectionTitle {
    switch (_selectedSection) {
      case 'tables':
        return 'Masa Durumları';
      case 'issues':
        return 'Sorun Bildirimleri';
      case 'queues':
        return 'Sıra Kayıtları';
      case 'qr':
        return 'QR Kayıtları';
      case 'locations':
        return 'Konum Alanları';
      case 'notifications':
        return 'Bildirimler';
      default:
        return 'Masa Durumları';
    }
  }

  IconData get _selectedSectionIcon {
    switch (_selectedSection) {
      case 'tables':
        return Icons.event_seat_rounded;
      case 'issues':
        return Icons.report_problem_outlined;
      case 'queues':
        return Icons.groups_2_outlined;
      case 'qr':
        return Icons.qr_code_2;
      case 'locations':
        return Icons.location_on_outlined;
      case 'notifications':
        return Icons.notifications_none;
      default:
        return Icons.event_seat_rounded;
    }
  }

  int get _selectedSectionCount {
    switch (_selectedSection) {
      case 'tables':
        return _tables.length;
      case 'issues':
        return _issueReports.length;
      case 'queues':
        return _queueEntries.length;
      case 'qr':
        return _qrCodeRecords.length;
      case 'locations':
        return _locationAreas.length;
      case 'notifications':
        return _notifications.length;
      default:
        return _tables.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Görevli Paneli'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loadStaffPanelData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Çıkış Yap',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStaffPanelData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Veriler yüklenirken hata oluştu:\n$_errorMessage',
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 16),
        _buildFeatureCards(),
        const SizedBox(height: 20),
        _buildSelectedSectionHeader(),
        const SizedBox(height: 10),
        _buildSelectedSectionContent(),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF1E3A8A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.badge_outlined,
                color: Color(0xFF1E3A8A),
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş geldin ${widget.fullName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rol: ${widget.role}',
                    style: const TextStyle(
                      color: Color(0xFFE0E7FF),
                      fontSize: 14,
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

  Widget _buildFeatureCards() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildFeatureCard(
          section: 'tables',
          title: 'Masa Durumları',
          value: _tables.length.toString(),
          subtitle: 'Boş: $_availableTableCount / Dolu: $_occupiedTableCount',
          icon: Icons.event_seat_rounded,
          color: const Color(0xFF16A34A),
        ),
        _buildFeatureCard(
          section: 'issues',
          title: 'Sorun Bildirimleri',
          value: _issueReports.length.toString(),
          subtitle: 'Açık: $_openIssueCount',
          icon: Icons.report_problem_outlined,
          color: const Color(0xFFF59E0B),
        ),
        _buildFeatureCard(
          section: 'queues',
          title: 'Sıra Kayıtları',
          value: _queueEntries.length.toString(),
          subtitle: 'Bekleyen: $_waitingQueueCount',
          icon: Icons.groups_2_outlined,
          color: const Color(0xFF2563EB),
        ),
        _buildFeatureCard(
          section: 'qr',
          title: 'QR Kayıtları',
          value: _qrCodeRecords.length.toString(),
          subtitle: 'Aktif: $_activeQrCodeCount',
          icon: Icons.qr_code_2,
          color: const Color(0xFF7C3AED),
        ),
        _buildFeatureCard(
          section: 'locations',
          title: 'Konum Alanları',
          value: _locationAreas.length.toString(),
          subtitle: 'Aktif: $_activeLocationAreaCount',
          icon: Icons.location_on_outlined,
          color: const Color(0xFF0891B2),
        ),
        _buildFeatureCard(
          section: 'notifications',
          title: 'Bildirimler',
          value: _notifications.length.toString(),
          subtitle: 'Okunmamış: $_unreadNotificationCount',
          icon: Icons.notifications_none,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String section,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedSection == section;

    return SizedBox(
      width: 170,
      child: InkWell(
        onTap: () => _selectSection(section),
        borderRadius: BorderRadius.circular(18),
        child: Card(
          elevation: isSelected ? 3 : 0,
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 1.3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSectionHeader() {
    return Row(
      children: [
        Icon(
          _selectedSectionIcon,
          color: const Color(0xFF1E3A8A),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _selectedSectionTitle,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        Chip(
          label: Text('$_selectedSectionCount kayıt'),
          backgroundColor: const Color(0xFFEFF6FF),
          labelStyle: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSectionContent() {
    switch (_selectedSection) {
      case 'tables':
        return _buildTableList();
      case 'issues':
        return _buildIssueReportList();
      case 'queues':
        return _buildQueueEntryList();
      case 'qr':
        return _buildQrCodeRecordList();
      case 'locations':
        return _buildLocationAreaList();
      case 'notifications':
        return _buildNotificationList();
      default:
        return _buildTableList();
    }
  }

  Widget _buildTableList() {
    if (_tables.isEmpty) {
      return _buildEmptyCard('Masa kaydı bulunamadı.');
    }

    return Column(
      children: _tables.map((table) {
        final color = _tableStatusColor(table);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: color,
              child: const Icon(
                Icons.event_seat_rounded,
                color: Colors.white,
              ),
            ),
            title: Text(
              table.code,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              table.locationAreaName.isEmpty
                  ? 'Konum alanı yok'
                  : table.locationAreaName,
            ),
            trailing: _buildStatusBadge(
              text: table.statusText,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIssueReportList() {
    if (_issueReports.isEmpty) {
      return _buildEmptyCard('Sorun bildirimi bulunamadı.');
    }

    return Column(
      children: _issueReports.map((issueReport) {
        final color = _issueStatusColor(issueReport);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Masa: ${issueReport.studyTableCode}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    _buildStatusBadge(
                      text: issueReport.statusText,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  issueReport.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bildiren: ${issueReport.userFullName.isEmpty ? '-' : issueReport.userFullName}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tarih: ${_formatDate(issueReport.createdAt)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _updateIssueStatus(
                          issueReport: issueReport,
                          status: 2,
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('İncele'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _updateIssueStatus(
                          issueReport: issueReport,
                          status: 3,
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Çözüldü'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _updateIssueStatus(
                          issueReport: issueReport,
                          status: 4,
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Reddet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQueueEntryList() {
    if (_queueEntries.isEmpty) {
      return _buildEmptyCard('Sıra kaydı bulunamadı.');
    }

    return Column(
      children: _queueEntries.map((queueEntry) {
        final color = _queueStatusColor(queueEntry);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Masa: ${queueEntry.studyTableCode}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    _buildStatusBadge(
                      text: queueEntry.statusText,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Öğrenci: ${queueEntry.userFullName.isEmpty ? '-' : queueEntry.userFullName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tarih: ${_formatDate(queueEntry.createdAt)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _updateQueueStatus(
                          queueEntry: queueEntry,
                          status: 2,
                        );
                      },
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Bildirim Gönderildi'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _updateQueueStatus(
                          queueEntry: queueEntry,
                          status: 3,
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Tamamlandı'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _updateQueueStatus(
                          queueEntry: queueEntry,
                          status: 4,
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('İptal Et'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQrCodeRecordList() {
    if (_qrCodeRecords.isEmpty) {
      return _buildEmptyCard('QR kaydı bulunamadı.');
    }

    return Column(
      children: _qrCodeRecords.map((qrCodeRecord) {
        final color = _activeStatusColor(qrCodeRecord.isActive);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      color: Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        qrCodeRecord.code.isEmpty
                            ? 'QR Kodu'
                            : qrCodeRecord.code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    _buildStatusBadge(
                      text: qrCodeRecord.statusText,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Masa: ${qrCodeRecord.studyTableCode.isEmpty ? '-' : qrCodeRecord.studyTableCode}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Oluşturulma: ${_formatDate(qrCodeRecord.createdAt)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _updateQrCodeStatus(
                          qrCodeRecord: qrCodeRecord,
                          isActive: !qrCodeRecord.isActive,
                        );
                      },
                      icon: Icon(
                        qrCodeRecord.isActive
                            ? Icons.toggle_off_outlined
                            : Icons.toggle_on_outlined,
                      ),
                      label: Text(
                        qrCodeRecord.isActive ? 'Pasif Yap' : 'Aktif Yap',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showQrCodeImage(qrCodeRecord),
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Görsel'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showQrDownloadPreview(qrCodeRecord),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('İndir'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showQrPrintHtml(qrCodeRecord),
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('Yazdır'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _copyQrEndpointLink(
                          qrCodeRecord: qrCodeRecord,
                          endpointType: 'download',
                        );
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('İndirme Linki'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _copyQrEndpointLink(
                          qrCodeRecord: qrCodeRecord,
                          endpointType: 'print',
                        );
                      },
                      icon: const Icon(Icons.link_outlined),
                      label: const Text('Yazdırma Linki'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationAreaList() {
    if (_locationAreas.isEmpty) {
      return _buildEmptyCard('Konum alanı bulunamadı.');
    }

    return Column(
      children: _locationAreas.map((locationArea) {
        final color = _activeStatusColor(locationArea.isActive);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: color,
              child: const Icon(
                Icons.location_on_outlined,
                color: Colors.white,
              ),
            ),
            title: Text(
              locationArea.name.isEmpty ? 'Konum Alanı' : locationArea.name,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              'Enlem: ${locationArea.latitude}\n'
              'Boylam: ${locationArea.longitude}\n'
              'Yarıçap: ${locationArea.radiusMeters} m',
            ),
            trailing: _buildStatusBadge(
              text: locationArea.statusText,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return _buildEmptyCard('Henüz bildirimin bulunmuyor.');
    }

    return Column(
      children: _notifications.map((notification) {
        final cardColor = notification.isRead
            ? Colors.grey.withValues(alpha: 0.10)
            : Colors.blue.withValues(alpha: 0.10);

        final borderColor = notification.isRead
            ? Colors.grey.withValues(alpha: 0.35)
            : Colors.blue.withValues(alpha: 0.50);

        return InkWell(
          onTap: () => _markNotificationAsRead(notification),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  notification.isRead
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                  color: notification.isRead ? Colors.grey : Colors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title.isEmpty
                            ? 'Bildirim'
                            : notification.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.isRead
                            ? 'Okundu'
                            : 'Okunmadı - dokununca okundu yapılır',
                        style: TextStyle(
                          color: notification.isRead
                              ? Colors.grey.shade600
                              : Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (notification.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(
                            notification.createdAt,
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
