import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine_model.dart';
import '../core/constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MedicineModelAdapter());
    await Hive.openBox<MedicineModel>(AppConstants.boxName);
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
