import 'package:hive/hive.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 1)
enum FrequencyType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  specificDays,
}

@HiveType(typeId: 0)
class MedicineModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int totalDoses;

  @HiveField(3)
  final int hour;

  @HiveField(4)
  final int minute;

  @HiveField(5)
  bool isDone;

  @HiveField(6)
  int remainingDoses;

  @HiveField(7)
  final FrequencyType frequencyType;

  @HiveField(8)
  final List<int> selectedDays;

  MedicineModel({
    required this.id,
    required this.name,
    required this.totalDoses,
    required this.hour,
    required this.minute,
    required this.frequencyType,
    required this.selectedDays,
    this.isDone = false,
    int? remainingDoses,
  }) : remainingDoses = remainingDoses ?? totalDoses;

  bool get isCompleted => remainingDoses <= 0;

  void takeDose() {
    if (remainingDoses > 0) {
      remainingDoses--;
      save();
    }
  }
}
