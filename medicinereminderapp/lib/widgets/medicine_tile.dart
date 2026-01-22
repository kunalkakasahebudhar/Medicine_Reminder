// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine_model.dart';
import '../providers/medicine_provider.dart';

class MedicineTile extends StatelessWidget {
  final MedicineModel medicine;

  const MedicineTile({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(hour: medicine.hour, minute: medicine.minute);
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: medicine.isDone
                ? Colors.transparent
                : theme.primaryColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: medicine.isDone
              ? Colors.grey.shade200
              : theme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            context.read<MedicineProvider>().toggleMedicineStatus(medicine);
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: medicine.isDone
                        ? Colors.grey.shade100
                        : theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: medicine.isDone ? Colors.grey : theme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: medicine.isDone ? Colors.grey : Colors.black87,
                          decoration: medicine.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Dose counter
                      Text(
                        medicine.isCompleted 
                            ? 'Completed' 
                            : '${medicine.remainingDoses}/${medicine.totalDoses} doses left',
                        style: TextStyle(
                          fontSize: 12,
                          color: medicine.isCompleted 
                              ? Colors.green 
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Frequency and Time info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: medicine.isDone
                                  ? Colors.grey.shade200
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getFrequencyText(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: medicine.isDone
                                    ? Colors.grey
                                    : Colors.blue.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: medicine.isDone
                                  ? Colors.grey.shade200
                                  : Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history_toggle_off_rounded,
                                  size: 14,
                                  color: medicine.isDone
                                      ? Colors.grey
                                      : Colors.teal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  time.format(context),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: medicine.isDone
                                        ? Colors.grey
                                        : Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        medicine.isDone
                            ? Icons.check_circle_rounded
                            : medicine.isCompleted
                                ? Icons.done_all_rounded
                                : Icons.radio_button_unchecked_rounded,
                        color: medicine.isDone
                            ? Colors.green
                            : medicine.isCompleted
                                ? Colors.grey
                                : theme.primaryColor,
                        size: 30,
                      ),
                      onPressed: medicine.isCompleted ? null : () {
                        context.read<MedicineProvider>().toggleMedicineStatus(
                          medicine,
                        );
                      },
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: () => _showDeleteDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete ${medicine.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<MedicineProvider>().deleteMedicine(medicine.id);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getFrequencyText() {
    switch (medicine.frequencyType) {
      case FrequencyType.daily:
        return 'Daily';
      case FrequencyType.weekly:
        return 'Weekly';
      case FrequencyType.specificDays:
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final selectedDayNames = medicine.selectedDays
            .map((day) => dayNames[day - 1])
            .join(', ');
        return selectedDayNames;
    }
  }
}
