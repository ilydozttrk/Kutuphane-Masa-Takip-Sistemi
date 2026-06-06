import 'package:flutter/material.dart';

import '../models/block_record_model.dart';
import '../services/block_record_service.dart';

class AdminBlockRecordsScreen extends StatefulWidget {
  const AdminBlockRecordsScreen({super.key});

  @override
  State<AdminBlockRecordsScreen> createState() =>
      _AdminBlockRecordsScreenState();
}

class _AdminBlockRecordsScreenState extends State<AdminBlockRecordsScreen> {
  final BlockRecordService _blockRecordService = BlockRecordService();

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController endsAtController = TextEditingController();

  List<BlockRecordModel> blockRecords = [];

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadBlockRecords();
  }

  @override
  void dispose() {
    userIdController.dispose();
    reasonController.dispose();
    endsAtController.dispose();
    super.dispose();
  }

  Future<void> loadBlockRecords() async {
    try {
      final result = await _blockRecordService.getAllBlockRecords();

      setState(() {
        blockRecords = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("BLOK LİSTE HATASI: $e");
    }
  }

  Future<void> createBlock() async {
    final userId = int.tryParse(userIdController.text.trim());
    final reason = reasonController.text.trim();
    final endsAt = endsAtController.text.trim();

    if (userId == null || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kullanıcı ID ve blok nedeni zorunludur."),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _blockRecordService.createBlockRecord(
        userId: userId,
        reason: reason,
        endsAt: endsAt.isEmpty ? null : endsAt,
      );

      userIdController.clear();
      reasonController.clear();
      endsAtController.clear();

      await loadBlockRecords();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı başarıyla bloke edildi.")),
      );
    } catch (e) {
      debugPrint("BLOK EKLEME HATASI: $e");
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> removeBlock(BlockRecordModel blockRecord) async {
    try {
      await _blockRecordService.removeBlock(blockRecordId: blockRecord.id);

      await loadBlockRecords();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Blok kaldırıldı.")));
    } catch (e) {
      debugPrint("BLOK KALDIRMA HATASI: $e");
    }
  }

  void showAddBlockDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kullanıcı Blokla"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: userIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Kullanıcı ID",
                    hintText: "Örn: 3",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: "Blok nedeni",
                    hintText: "Örn: Kurallara aykırı kullanım",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: endsAtController,
                  decoration: const InputDecoration(
                    labelText: "Bitiş tarihi (opsiyonel)",
                    hintText: "Örn: 2026-05-20T12:00:00",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      await createBlock();

                      if (!context.mounted) return;

                      Navigator.pop(context);
                    },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  Color getStatusColor(BlockRecordModel blockRecord) {
    return blockRecord.isActive ? Colors.red : Colors.grey;
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return "-";
    }

    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bloklama Yönetimi")),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddBlockDialog,
        child: const Icon(Icons.block),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: blockRecords.length,
              itemBuilder: (context, index) {
                final blockRecord = blockRecords[index];

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
                              backgroundColor: getStatusColor(blockRecord),
                              child: const Icon(
                                Icons.block,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                blockRecord.userFullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text("Email: ${blockRecord.userEmail}"),
                        const SizedBox(height: 6),
                        Text("Neden: ${blockRecord.reason}"),
                        const SizedBox(height: 6),
                        Text("Durum: ${blockRecord.statusText}"),
                        const SizedBox(height: 6),
                        Text("Başlangıç: ${formatDate(blockRecord.blockedAt)}"),
                        const SizedBox(height: 6),
                        Text("Bitiş: ${formatDate(blockRecord.endsAt)}"),
                        if (blockRecord.isActive) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                removeBlock(blockRecord);
                              },
                              icon: const Icon(Icons.lock_open),
                              label: const Text("Bloğu Kaldır"),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
