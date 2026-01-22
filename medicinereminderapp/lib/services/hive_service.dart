import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine_model.dart';
import '../core/constants.dart';

class HiveService {
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(MedicineModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(FrequencyTypeAdapter());
      }
      await Hive.openBox<MedicineModel>(AppConstants.boxName);
      print('HiveService: Box opened successfully');
    } catch (e) {
      print('HiveService: Error initializing Hive: $e');
      rethrow; // Rethrow to let main handle it
    }
  }

  Box<MedicineModel> get medicineBox =>
      Hive.box<MedicineModel>(AppConstants.boxName);

  List<MedicineModel> getMedicines() {
    return medicineBox.values.toList();
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    await medicineBox.put(medicine.id, medicine);
  }

  Future<void> deleteMedicine(int id) async {
    await medicineBox.delete(id);
  }
}
