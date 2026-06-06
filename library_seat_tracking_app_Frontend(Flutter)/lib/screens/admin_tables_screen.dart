import 'package:flutter/material.dart';

import '../models/location_area_model.dart';
import '../models/study_table_model.dart';
import '../services/location_area_service.dart';
import '../services/study_table_service.dart';

class AdminTablesScreen extends StatefulWidget {
  const AdminTablesScreen({super.key});

  @override
  State<AdminTablesScreen> createState() => _AdminTablesScreenState();
}

class _AdminTablesScreenState extends State<AdminTablesScreen> {
  final StudyTableService _studyTableService = StudyTableService();
  final LocationAreaService _locationAreaService = LocationAreaService();

  final TextEditingController codeController = TextEditingController();

  List<StudyTableModel> tables = [];
  List<LocationAreaModel> locationAreas = [];

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
      final tableResult = await _studyTableService.getStudyTables();
      final locationResult = await _locationAreaService.getLocationAreas();

      if (!mounted) return;

      setState(() {
        tables = tableResult;
        locationAreas = locationResult;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veriler yüklenirken hata oluştu: $e"),
        ),
      );
    }
  }

  Future<void> loadTables() async {
    try {
      final result = await _studyTableService.getStudyTables();

      if (!mounted) return;

      setState(() {
        tables = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Masa listesi alınırken hata oluştu: $e"),
        ),
      );
    }
  }

  Future<bool> createStudyTable({
    required int locationAreaId,
  }) async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Masa kodu boş bırakılamaz."),
        ),
      );
      return false;
    }

    try {
      await _studyTableService.createStudyTable(
        code: code,
        locationAreaId: locationAreaId,
      );

      codeController.clear();

      await loadTables();

      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Masa başarıyla eklendi."),
        ),
      );

      return true;
    } catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Masa eklenirken hata oluştu: $e"),
        ),
      );

      return false;
    }
  }

  void showAddTableDialog() {
    codeController.clear();

    int? selectedLocationAreaId =
        locationAreas.isNotEmpty ? locationAreas.first.id : null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isDialogSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Yeni Masa Ekle"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: codeController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Masa kodu",
                        hintText: "Örn: A-102",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (locationAreas.isEmpty)
                      const Text(
                        "Konum alanı bulunamadı. Önce konum alanı eklenmelidir.",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: selectedLocationAreaId,
                        decoration: const InputDecoration(
                          labelText: "Konum alanı",
                          border: OutlineInputBorder(),
                        ),
                        items: locationAreas.map((area) {
                          return DropdownMenuItem<int>(
                            value: area.id,
                            child: Text(
                              area.name.isEmpty
                                  ? "Konum Alanı #${area.id}"
                                  : area.name,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedLocationAreaId = value;
                          });
                        },
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
                  onPressed: isDialogSaving || selectedLocationAreaId == null
                      ? null
                      : () async {
                          setDialogState(() {
                            isDialogSaving = true;
                          });

                          final success = await createStudyTable(
                            locationAreaId: selectedLocationAreaId!,
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
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

  Color getStatusColor(StudyTableModel table) {
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

  String getStatusText(StudyTableModel table) {
    if (table.isAvailable) {
      return "Boş";
    }

    if (table.isOccupied) {
      return "Dolu";
    }

    if (table.isReserved) {
      return "Rezerve";
    }

    if (table.isMaintenance) {
      return "Bakımda";
    }

    return "Bilinmiyor";
  }

  Future<void> updateTableStatus({
    required StudyTableModel table,
    required int status,
  }) async {
    try {
      await _studyTableService.updateStudyTableStatus(
        studyTableId: table.id,
        status: status,
      );

      await loadTables();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Masa durumu güncellendi."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Masa durumu güncellenirken hata oluştu: $e"),
        ),
      );
    }
  }

  Widget buildTableCard(StudyTableModel table) {
    final statusColor = getStatusColor(table);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: const Icon(
            Icons.event_seat,
            color: Colors.white,
          ),
        ),
        title: Text(
          table.code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              table.locationAreaName.isEmpty
                  ? "Alan: Belirtilmemiş"
                  : "Alan: ${table.locationAreaName}",
            ),
            const SizedBox(height: 6),
            DropdownButton<int>(
              value: table.status,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 1,
                  child: Text("Boş"),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text("Dolu"),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text("Rezerve"),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Text("Bakımda"),
                ),
              ],
              onChanged: (value) async {
                if (value == null) return;

                await updateTableStatus(
                  table: table,
                  status: value,
                );
              },
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              table.isAvailable ? Icons.check_circle : Icons.info_outline,
              color: statusColor,
            ),
            const SizedBox(height: 4),
            Text(
              getStatusText(table),
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("Masa Yönetimi"),
        actions: [
          IconButton(
            tooltip: "Yenile",
            onPressed: loadPageData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTableDialog,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : tables.isEmpty
              ? const Center(
                  child: Text("Henüz masa kaydı bulunamadı."),
                )
              : RefreshIndicator(
                  onRefresh: loadPageData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];

                      return buildTableCard(table);
                    },
                  ),
                ),
    );
  }
}