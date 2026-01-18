import 'package:hive/hive.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 0)
class MedicineModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dose;

  @HiveField(3)
  final int hour;

  @HiveField(4)
  final int minute;

  MedicineModel({
    required this.id,
    required this.name,
    required this.dose,
    required this.hour,
    required this.minute,
  });
}
