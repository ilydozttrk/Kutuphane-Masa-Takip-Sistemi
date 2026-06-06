import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification_model.dart';
import '../models/issue_report_model.dart';
import '../models/queue_entry_model.dart';
import '../models/reservation_model.dart';
import '../models/study_table_model.dart';
import '../services/api_client.dart';
import '../services/app_notification_service.dart';
import '../services/issue_report_service.dart';
import '../services/location_service.dart';
import '../services/queue_entry_service.dart';
import '../services/reservation_service.dart';
import '../services/study_table_service.dart';
import 'login_screen.dart';
import 'qr_scanner_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final String? fullName;
  final String? role;

  const StudentHomeScreen({
    super.key,
    this.fullName,
    this.role,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final StudyTableService _studyTableService = StudyTableService();
  final ReservationService _reservationService = ReservationService();
  final LocationService _locationService = LocationService();
  final QueueEntryService _queueEntryService = QueueEntryService();
  final IssueReportService _issueReportService = IssueReportService();
  final AppNotificationService _appNotificationService =
      AppNotificationService();

  bool _isLoading = true;
  bool _isReservationProcessing = false;
  String? _errorMessage;

  List<StudyTableModel> _tables = [];
  ReservationModel? _activeReservation;
  List<QueueEntryModel> _queueEntries = [];
  List<IssueReportModel> _issueReports = [];
  List<AppNotificationModel> _notifications = [];

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadStudentHomeData();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (!mounted) return;

        setState(() {
          // Kalan süre ekranda güncel görünsün diye boş setState.
          // Süre kuralı frontend'de verilmez, backend tarafından yönetilir.
        });
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStudentHomeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _studyTableService.getStudyTables(),
        _reservationService.getActiveReservation(),
        _queueEntryService.getMyQueueEntries(),
        _issueReportService.getMyIssueReports(),
        _appNotificationService.getMyNotifications(),
      ]);

      final tables = results[0] as List<StudyTableModel>;
      final activeReservation = results[1] as ReservationModel?;
      final queueEntries = results[2] as List<QueueEntryModel>;
      final issueReports = results[3] as List<IssueReportModel>;
      final notifications = results[4] as List<AppNotificationModel>;

      if (!mounted) return;

      setState(() {
        _tables = tables;
        _activeReservation = activeReservation;
        _queueEntries = queueEntries;
        _issueReports = issueReports;
        _notifications = notifications;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Masa, sıra, sorun ve bildirim bilgileri alınırken beklenmeyen bir hata oluştu.';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Hesabından çıkış yapmak istiyor musun?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('role');
    await prefs.remove('fullName');
    await prefs.remove('email');
    await prefs.remove('userId');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
  Color _getTableColor(StudyTableModel table) {
    if (table.isAvailable) {
      return Colors.green;
    }

    if (table.isOccupied) {
      return Colors.red;
    }

    if (table.isReserved) {
      return Colors.orange;
    }

    if (table.isMaintenance) {
      return Colors.grey;
    }

    return Colors.blueGrey;
  }

  IconData _getTableIcon(StudyTableModel table) {
    if (table.isAvailable) {
      return Icons.event_seat;
    }

    if (table.isOccupied) {
      return Icons.person;
    }

    if (table.isReserved) {
      return Icons.access_time;
    }

    if (table.isMaintenance) {
      return Icons.build;
    }

    return Icons.help_outline;
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _getRemainingTimeText() {
    final endTime = _activeReservation?.endTime;

    if (endTime == null) {
      return '-';
    }

    final difference = endTime.difference(DateTime.now());

    if (difference.isNegative) {
      return 'Süre dolmuş görünüyor';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '$hours saat $minutes dakika';
    }

    return '$minutes dakika';
  }

  Future<bool> _showReservationConfirmDialog(String qrCode) async {
    final hasActiveReservation = _activeReservation != null;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            hasActiveReservation ? 'Rezervasyonu Yenile' : 'Rezervasyon Oluştur',
          ),
          content: Text(
            hasActiveReservation
                ? 'Aktif rezervasyonun var. Okutulan QR kod ile yenileme isteği göndermek istiyor musun?\n\nQR Kod: $qrCode'
                : 'Bu masa için rezervasyon oluşturmak istiyor musun?\n\nQR Kod: $qrCode',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                hasActiveReservation ? 'Yenile' : 'Oluştur',
              ),
            ),
          ],
        );
      },
    );

    return confirm == true;
  }

  Future<void> _onQrButtonPressed() async {
    if (_isReservationProcessing) {
      return;
    }

    final qrCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QrScannerScreen(),
      ),
    );

    if (!mounted) return;

    if (qrCode == null || qrCode.trim().isEmpty) {
      return;
    }

    final confirmed = await _showReservationConfirmDialog(qrCode);

    if (!mounted) return;

    if (!confirmed) {
      return;
    }

    setState(() {
      _isReservationProcessing = true;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konum bilgisi alınıyor...'),
          duration: Duration(seconds: 1),
        ),
      );

      final location = await _locationService.getCurrentLocation();

      if (!mounted) return;

      if (_activeReservation == null) {
        await _reservationService.createReservation(
          qrCode: qrCode,
          userLatitude: location.latitude,
          userLongitude: location.longitude,
          durationMinutes: 60,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rezervasyon başarıyla oluşturuldu.'),
          ),
        );
      } else {
        await _reservationService.renewReservation(
          qrCode: qrCode,
          userLatitude: location.latitude,
          userLongitude: location.longitude,
          extraMinutes: 60,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rezervasyon başarıyla yenilendi.'),
          ),
        );
      }

      await _loadStudentHomeData();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isReservationProcessing = false;
        });
      }
    }
  }

  Future<void> _completeReservation() async {
    final reservation = _activeReservation;

    if (reservation == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rezervasyonu Bitir'),
          content: Text(
            '${reservation.studyTableCode} numaralı masa için aktif rezervasyonunu bitirmek istiyor musun?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Bitir'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _reservationService.completeReservation(
        reservationId: reservation.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rezervasyon başarıyla bitirildi.'),
        ),
      );

      await _loadStudentHomeData();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rezervasyon bitirilirken bir hata oluştu.'),
        ),
      );
    }
  }

  Future<void> _joinQueue(StudyTableModel table) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sıraya Gir'),
          content: Text(
            '${table.code} numaralı masa için sıraya girmek istiyor musun?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sıraya Gir'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _queueEntryService.createQueueEntry(
        studyTableId: table.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${table.code} masası için sıraya girildi.'),
        ),
      );

      await _loadStudentHomeData();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sıraya girme işlemi sırasında bir hata oluştu.'),
        ),
      );
    }
  }

  Future<void> _showIssueReportDialog(StudyTableModel table) async {
    String description = '';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sorun Bildir'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${table.code} masası için sorun bildirimi oluşturulacak.'),
                const SizedBox(height: 12),
                TextField(
                  maxLines: 4,
                  maxLength: 500,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) {
                    description = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Sorun açıklaması',
                    hintText: 'Örn: Masanın prizi çalışmıyor.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                final trimmedDescription = description.trim();

                if (trimmedDescription.length < 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Sorun açıklaması en az 5 karakter olmalıdır.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, trimmedDescription);
              },
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (result == null || result.trim().isEmpty) {
      return;
    }

    try {
      await _issueReportService.createIssueReport(
        studyTableId: table.id,
        description: result.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${table.code} masası için sorun bildirildi.'),
        ),
      );

      await _loadStudentHomeData();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sorun bildirimi gönderilirken bir hata oluştu.'),
        ),
      );
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

      await _loadStudentHomeData();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bildirim okundu yapılırken bir hata oluştu.'),
        ),
      );
    }
  }

  Widget _buildWelcomeCard() {
    final fullName = widget.fullName ?? 'Öğrenci';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoş geldin, $fullName ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Kütüphane masalarının güncel durumunu buradan görebilirsin.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveReservationCard() {
    final reservation = _activeReservation;

    if (reservation == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          'Şu anda aktif rezervasyonun bulunmuyor.',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktif Rezervasyon',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text('Masa: ${reservation.studyTableCode}'),
          Text('Başlangıç: ${_formatDateTime(reservation.startTime)}'),
          Text('Bitiş: ${_formatDateTime(reservation.endTime)}'),
          Text('Kalan süre: ${_getRemainingTimeText()}'),
          const SizedBox(height: 8),
          Text(
            'Rezervasyon süreci backend tarafından takip edilir. Aynı masanın QR kodunu okutarak yenileme isteği gönderebilirsin.',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _completeReservation,
              icon: const Icon(Icons.logout),
              label: const Text('Rezervasyonu Bitir'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueEntriesSection() {
    final activeQueueEntries = _queueEntries
        .where((entry) => entry.isWaiting || entry.isNotified)
        .toList();

    if (activeQueueEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sıra Durumlarım',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...activeQueueEntries.map((entry) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.groups_rounded,
                  color: Colors.amber,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.studyTableCode,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        entry.statusText,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIssueReportsSection() {
    final activeIssueReports = _issueReports
        .where((report) => report.isOpen || report.isInProgress)
        .toList();

    if (activeIssueReports.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sorun Bildirimlerim',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...activeIssueReports.map((report) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.deepPurple.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.report_problem_outlined,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.studyTableCode,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        report.statusText,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNotificationsDrawer() {
    final unreadCount =
        _notifications.where((notification) => !notification.isRead).length;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blue.shade100,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.blue,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Bildirimlerim',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _notifications.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Henüz bildirimin bulunmuyor.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];

                        final cardColor = notification.isRead
                            ? Colors.grey.withValues(alpha: 0.10)
                            : Colors.blue.withValues(alpha: 0.10);

                        final borderColor = notification.isRead
                            ? Colors.grey.withValues(alpha: 0.35)
                            : Colors.blue.withValues(alpha: 0.50);

                        return InkWell(
                          onTap: () => _markNotificationAsRead(notification),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
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
                                  color: notification.isRead
                                      ? Colors.grey
                                      : Colors.blue,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          _formatDateTime(
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isReservationProcessing ? null : _onQrButtonPressed,
        icon: _isReservationProcessing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.qr_code_scanner),
        label: Text(
          _isReservationProcessing ? 'İşlem Yapılıyor...' : 'QR Okut',
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard(StudyTableModel table) {
    final color = _getTableColor(table);
    final hasActiveReservation = _activeReservation != null;

    final alreadyInQueueForThisTable = _queueEntries.any(
      (entry) =>
          entry.studyTableId == table.id &&
          (entry.isWaiting || entry.isNotified),
    );

    final canJoinQueue = !hasActiveReservation &&
        !alreadyInQueueForThisTable &&
        (table.isOccupied || table.isReserved);

    final showQueueInfo =
        hasActiveReservation && (table.isOccupied || table.isReserved);

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.65),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getTableIcon(table),
            color: color,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            table.code,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            table.statusText,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (table.locationAreaName.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              table.locationAreaName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
              ),
            ),
          ],
          if (canJoinQueue) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: OutlinedButton.icon(
                onPressed: () => _joinQueue(table),
                icon: const Icon(
                  Icons.groups_rounded,
                  size: 16,
                ),
                label: const Text(
                  'Sıraya Gir',
                  style: TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
          if (showQueueInfo) ...[
            const SizedBox(height: 10),
            Text(
              'Aktif rezervasyon varken sıraya girilemez.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (alreadyInQueueForThisTable && !hasActiveReservation) ...[
            const SizedBox(height: 10),
            Text(
              'Bu masa için zaten sıradasın.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: OutlinedButton.icon(
              onPressed: () => _showIssueReportDialog(table),
              icon: const Icon(
                Icons.report_problem_outlined,
                size: 16,
              ),
              label: const Text(
                'Sorun Bildir',
                style: TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableGrid() {
    if (_tables.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Henüz masa bilgisi bulunamadı.'),
        ),
      );
    }

    return GridView.builder(
      itemCount: _tables.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final table = _tables[index];
        return _buildTableCard(table);
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Bir hata oluştu.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadStudentHomeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
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
      return _buildErrorView();
    }

    final hasActiveQueueEntries = _queueEntries
        .where((entry) => entry.isWaiting || entry.isNotified)
        .isNotEmpty;

    final hasActiveIssueReports = _issueReports
        .where((report) => report.isOpen || report.isInProgress)
        .isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadStudentHomeData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 16),
          _buildQrButton(),
          const SizedBox(height: 16),
          _buildActiveReservationCard(),
          const SizedBox(height: 22),
          _buildQueueEntriesSection(),
          if (hasActiveQueueEntries) const SizedBox(height: 22),
          _buildIssueReportsSection(),
          if (hasActiveIssueReports) const SizedBox(height: 22),
          const Text(
            'Masa Durumları',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTableGrid(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _notifications.where((notification) => !notification.isRead).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildNotificationsDrawer(),
      appBar: AppBar(
        title: const Text('Öğrenci Paneli'),
        actions: [
          Builder(
            builder: (buttonContext) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      Scaffold.of(buttonContext).openEndDrawer();
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loadStudentHomeData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Çıkış Yap',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
