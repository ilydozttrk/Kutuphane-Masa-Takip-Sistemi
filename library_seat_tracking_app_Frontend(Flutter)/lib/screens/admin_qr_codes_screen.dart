import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../models/qr_code_record_model.dart';
import '../models/study_table_model.dart';
import '../services/qr_code_record_service.dart';
import '../services/study_table_service.dart';

class AdminQrCodesScreen extends StatefulWidget {
  const AdminQrCodesScreen({super.key});

  @override
  State<AdminQrCodesScreen> createState() => _AdminQrCodesScreenState();
}

class _AdminQrCodesScreenState extends State<AdminQrCodesScreen> {
  final QrCodeRecordService _qrCodeRecordService = QrCodeRecordService();
  final StudyTableService _studyTableService = StudyTableService();

  final TextEditingController codeController = TextEditingController();

  List<QrCodeRecordModel> qrCodes = [];
  List<StudyTableModel> tables = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPageData();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> loadPageData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final qrResult = await _qrCodeRecordService.getQrCodes();
      final tableResult = await _studyTableService.getStudyTables();

      if (!mounted) return;

      setState(() {
        qrCodes = qrResult;
        tables = tableResult;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("QR verileri yüklenirken hata oluştu: $e"),
        ),
      );
    }
  }

  List<StudyTableModel> get tablesWithoutQr {
    return tables.where((table) {
      final hasQr = qrCodes.any((qrCode) => qrCode.studyTableId == table.id);
      return !hasQr;
    }).toList();
  }

  StudyTableModel? findTableById(int id) {
    try {
      return tables.firstWhere((table) => table.id == id);
    } catch (_) {
      return null;
    }
  }

  String buildDefaultQrCode(StudyTableModel table) {
    final cleanedCode = table.code.trim().replaceAll(' ', '-').toUpperCase();
    return 'QR-$cleanedCode';
  }

  Future<bool> createQrCode({
    required int studyTableId,
  }) async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("QR kod alanı boş bırakılamaz."),
        ),
      );
      return false;
    }

    try {
      await _qrCodeRecordService.createQrCode(
        code: code,
        studyTableId: studyTableId,
      );

      codeController.clear();

      await loadPageData();

      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("QR başarıyla oluşturuldu."),
        ),
      );

      return true;
    } catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("QR oluşturulurken hata oluştu: $e"),
        ),
      );

      return false;
    }
  }

  Future<void> updateQrStatus({
    required QrCodeRecordModel qrCode,
    required bool isActive,
  }) async {
    try {
      await _qrCodeRecordService.updateQrStatus(
        qrCodeId: qrCode.id,
        isActive: isActive,
      );

      await loadPageData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("QR durumu güncellendi."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("QR durumu güncellenirken hata oluştu: $e"),
        ),
      );
    }
  }

  Future<Uint8List?> loadQrImage(int qrCodeId) async {
    try {
      return await _qrCodeRecordService.getQrCodeImageBytes(
        qrCodeRecordId: qrCodeId,
      );
    } catch (e) {
      debugPrint("QR IMAGE HATASI: $e");
      return null;
    }
  }

  Future<void> downloadQrImage(QrCodeRecordModel qrCode) async {
    try {
      final bytes = await _qrCodeRecordService.downloadQrCodeBytes(
        qrCodeRecordId: qrCode.id,
      );

      final directory = await getApplicationDocumentsDirectory();

      final safeTableCode = qrCode.studyTableCode
          .trim()
          .replaceAll(' ', '_')
          .replaceAll('/', '_');

      final file = File(
        '${directory.path}/qr_${safeTableCode}_${qrCode.id}.png',
      );

      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("QR indirildi ve açıldı."),
        ),
      );
    } catch (e) {
      debugPrint("QR DOWNLOAD HATASI: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("QR indirme hatası: $e"),
        ),
      );
    }
  }

  void showQrImageDialog(QrCodeRecordModel qrCode) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  qrCode.code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  qrCode.studyTableCode.isEmpty
                      ? "Masa bilgisi yok"
                      : "Masa: ${qrCode.studyTableCode}",
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Uint8List?>(
                  future: loadQrImage(qrCode.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Text("QR yüklenemedi.");
                    }

                    return Image.memory(
                      snapshot.data!,
                      height: 220,
                      width: 220,
                      fit: BoxFit.contain,
                    );
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text("Kapat"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAddQrDialog() {
    final availableTables = tablesWithoutQr;

    if (availableTables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "QR oluşturulabilecek masa bulunamadı. Tüm masaların QR kaydı olabilir.",
          ),
        ),
      );
      return;
    }

    int selectedStudyTableId = availableTables.first.id;
    codeController.text = buildDefaultQrCode(availableTables.first);

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isDialogSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("QR Oluştur"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedStudyTableId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Masa seç",
                        border: OutlineInputBorder(),
                      ),
                      items: availableTables.map((table) {
                        final tableText = table.locationAreaName.isEmpty
                            ? table.code
                            : "${table.code} - ${table.locationAreaName}";

                        return DropdownMenuItem<int>(
                          value: table.id,
                          child: Text(
                            tableText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        final selectedTable = findTableById(value);

                        setDialogState(() {
                          selectedStudyTableId = value;

                          if (selectedTable != null) {
                            codeController.text =
                                buildDefaultQrCode(selectedTable);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: codeController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: "QR kod",
                        hintText: "Örn: QR-A-102",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "QR kod değeri varsayılan olarak seçilen masa koduna göre oluşturulur. Gerekirse düzenleyebilirsin.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDialogSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text("İptal"),
                ),
                ElevatedButton(
                  onPressed: isDialogSaving
                      ? null
                      : () async {
                          setDialogState(() {
                            isDialogSaving = true;
                          });

                          final success = await createQrCode(
                            studyTableId: selectedStudyTableId,
                          );

                          if (!context.mounted) return;

                          setDialogState(() {
                            isDialogSaving = false;
                          });

                          if (success && dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: isDialogSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Kaydet"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color getStatusColor(QrCodeRecordModel qrCode) {
    return qrCode.isActive ? Colors.green : Colors.red;
  }

  Widget buildQrCard(QrCodeRecordModel qrCode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: getStatusColor(qrCode),
                  child: const Icon(
                    Icons.qr_code,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        qrCode.studyTableCode.isEmpty
                            ? "Masa bilgisi yok"
                            : "Masa: ${qrCode.studyTableCode}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Kod: ${qrCode.code}"),
                      Text("Durum: ${qrCode.statusText}"),
                    ],
                  ),
                ),
                Switch(
                  value: qrCode.isActive,
                  onChanged: (value) async {
                    await updateQrStatus(
                      qrCode: qrCode,
                      isActive: value,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showQrImageDialog(qrCode);
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Görüntüle"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      downloadQrImage(qrCode);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("İndir"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          "Henüz QR kaydı bulunamadı. Sağ alttaki + butonu ile QR oluşturabilirsin.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missingQrCount = tablesWithoutQr.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("QR Yönetimi"),
        actions: [
          IconButton(
            tooltip: "Yenile",
            onPressed: loadPageData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddQrDialog,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadPageData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF1E3A8A),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Toplam QR: ${qrCodes.length} | QR olmayan masa: $missingQrCount",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (qrCodes.isEmpty)
                    buildEmptyView()
                  else
                    ...qrCodes.map(buildQrCard),
                ],
              ),
            ),
    );
  }
}
