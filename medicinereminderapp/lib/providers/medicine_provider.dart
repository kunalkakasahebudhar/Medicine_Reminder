import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class MedicineProvider with ChangeNotifier {
  final HiveService _hiveService;
  List<MedicineModel> _medicines = [];

  MedicineProvider(this._hiveService) {
    _loadMedicines();
  }

  List<MedicineModel> get medicines => _medicines;

  void _loadMedicines() {
    _medicines = _hiveService.getMedicines();
    _sortMedicines();
    notifyListeners();
  }

  void _sortMedicines() {
    _medicines.sort((a, b) {
      if (a.hour != b.hour) {
        return a.hour.compareTo(b.hour);
      }
      return a.minute.compareTo(b.minute);
    });
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    print(
      'Adding medicine: ${medicine.name} at ${medicine.hour}:${medicine.minute}',
    );
    await _hiveService.addMedicine(medicine);

    // Schedule notification
    try {
      await NotificationService.scheduleNotification(
        id: medicine.id,
        title: 'Medicine Reminder',
        body: 'Time to take ${medicine.name}',
        hour: medicine.hour,
        minute: medicine.minute,
      );
      print('Notification scheduled successfully for ${medicine.name}');
    } catch (e) {
      print('Error scheduling notification: $e');
    }

    _loadMedicines();
  }

  Future<void> deleteMedicine(int id) async {
    await _hiveService.deleteMedicine(id);
    await NotificationService.cancelNotification(id);
    _loadMedicines();
  }
}
