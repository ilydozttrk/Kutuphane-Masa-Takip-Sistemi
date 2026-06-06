import 'package:flutter/material.dart';

import '../models/queue_entry_model.dart';
import '../services/queue_entry_service.dart';

class AdminQueueEntriesScreen extends StatefulWidget {
  const AdminQueueEntriesScreen({super.key});

  @override
  State<AdminQueueEntriesScreen> createState() =>
      _AdminQueueEntriesScreenState();
}

class _AdminQueueEntriesScreenState extends State<AdminQueueEntriesScreen> {
  final QueueEntryService _queueEntryService = QueueEntryService();

  List<QueueEntryModel> entries = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      final result = await _queueEntryService.getAllQueueEntries();

      setState(() {
        entries = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("QUEUE HATASI: $e");
    }
  }

  Color getStatusColor(QueueEntryModel entry) {
    if (entry.isWaiting) {
      return Colors.orange;
    }

    if (entry.isNotified) {
      return Colors.blue;
    }

    if (entry.isCompleted) {
      return Colors.green;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sıra Yönetimi")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];

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
                              backgroundColor: getStatusColor(entry),
                              child: const Icon(
                                Icons.people,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.userFullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text("Masa: ${entry.studyTableCode}"),
                        const SizedBox(height: 6),
                        DropdownButton<int>(
                          value: entry.status,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text("Bekliyor")),
                            DropdownMenuItem(
                              value: 2,
                              child: Text("Bildirim Gönderildi"),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text("Tamamlandı"),
                            ),
                            DropdownMenuItem(
                              value: 4,
                              child: Text("İptal Edildi"),
                            ),
                          ],
                          onChanged: (value) async {
                            if (value == null) return;

                            try {
                              await _queueEntryService.updateQueueEntryStatus(
                                queueEntryId: entry.id,
                                status: value,
                              );

                              await loadEntries();

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Sıra durumu güncellendi."),
                                ),
                              );
                            } catch (e) {
                              debugPrint("QUEUE STATUS HATASI: $e");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
