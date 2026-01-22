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
    try {
      _medicines = _hiveService.getMedicines();
      _sortMedicines();
      notifyListeners();
    } catch (e) {
      debugPrint('MedicineProvider: Error loading medicines: $e');
      _medicines = [];
      notifyListeners();
    }
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

    // Schedule notification only if medicine is not completed
    if (!medicine.isCompleted) {
      try {
        await NotificationService.scheduleNotification(
          id: medicine.id,
          title: 'Medicine Reminder',
          body: 'Time to take ${medicine.name} (${medicine.remainingDoses} doses left)',
          hour: medicine.hour,
          minute: medicine.minute,
          selectedDays: medicine.selectedDays,
        );
        print('Notification scheduled successfully for ${medicine.name}');
      } catch (e) {
        print('Error scheduling notification: $e');
      }
    }

    _loadMedicines();
  }

  Future<void> deleteMedicine(int id) async {
    final medicine = _medicines.firstWhere((m) => m.id == id);
    await _hiveService.deleteMedicine(id);
    await NotificationService.cancelNotification(id, medicine.selectedDays);
    _loadMedicines();
  }

  Future<void> toggleMedicineStatus(MedicineModel medicine) async {
    medicine.isDone = !medicine.isDone;
    
    // If marking as done, reduce dose count
    if (medicine.isDone && medicine.remainingDoses > 0) {
      medicine.takeDose();
      
      // If all doses are completed, cancel future notifications
      if (medicine.isCompleted) {
        await NotificationService.cancelNotification(medicine.id, medicine.selectedDays);
        print('All doses completed for ${medicine.name}. Notifications cancelled.');
      }
    }
    
    await medicine.save();
    notifyListeners();
  }
}
