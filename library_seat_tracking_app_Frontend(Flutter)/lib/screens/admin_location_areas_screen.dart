import 'package:flutter/material.dart';

import '../models/location_area_model.dart';
import '../services/location_area_service.dart';

class AdminLocationAreasScreen extends StatefulWidget {
  const AdminLocationAreasScreen({super.key});

  @override
  State<AdminLocationAreasScreen> createState() =>
      _AdminLocationAreasScreenState();
}

class _AdminLocationAreasScreenState extends State<AdminLocationAreasScreen> {
  final LocationAreaService _locationAreaService = LocationAreaService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();

  List<LocationAreaModel> areas = [];

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadAreas();
  }

  @override
  void dispose() {
    nameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    radiusController.dispose();
    super.dispose();
  }

  Future<void> loadAreas() async {
    try {
      final result = await _locationAreaService.getLocationAreas();

      setState(() {
        areas = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("ALAN HATASI: $e");
    }
  }

  Future<void> createArea() async {
    final name = nameController.text.trim();
    final latitude = double.tryParse(latitudeController.text.trim());
    final longitude = double.tryParse(longitudeController.text.trim());
    final radiusMeters = int.tryParse(radiusController.text.trim());

    if (name.isEmpty ||
        latitude == null ||
        longitude == null ||
        radiusMeters == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tüm alanları geçerli şekilde doldurun.")),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _locationAreaService.createLocationArea(
        name: name,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );

      nameController.clear();
      latitudeController.clear();
      longitudeController.clear();
      radiusController.clear();

      await loadAreas();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Alan başarıyla eklendi.")));
    } catch (e) {
      debugPrint("ALAN EKLEME HATASI: $e");
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void showAddAreaDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Alan Ekle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Alan adı",
                    hintText: "Örn: 1. Kat Sessiz Alan",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Latitude",
                    hintText: "Örn: 38.4012",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: longitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Longitude",
                    hintText: "Örn: 42.1234",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: radiusController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Yarıçap (metre)",
                    hintText: "Örn: 100",
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
                      await createArea();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alan Yönetimi")),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddAreaDialog,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: areas.length,
              itemBuilder: (context, index) {
                final area = areas[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.location_on)),
                    title: Text(area.name),
                    subtitle: Text("ID: ${area.id}"),
                  ),
                );
              },
            ),
    );
  }
}
