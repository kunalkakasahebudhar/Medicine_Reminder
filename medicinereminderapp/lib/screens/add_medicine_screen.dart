import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _nameController = TextEditingController();
  final _totalDosesController = TextEditingController();
  TimeOfDay? _selectedTime;
  FrequencyType _frequencyType = FrequencyType.daily;
  List<int> _selectedDays = [];

  final List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _totalDosesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Widget _buildDaySelector() {
    if (_frequencyType != FrequencyType.specificDays) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'SELECT DAYS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isSelected = _selectedDays.contains(dayNumber);
            return FilterChip(
              label: Text(_dayNames[index].substring(0, 3)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(dayNumber);
                  } else {
                    _selectedDays.remove(dayNumber);
                  }
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Future<void> _saveMedicine() async {
    final name = _nameController.text.trim();
    final totalDosesText = _totalDosesController.text.trim();

    if (name.isEmpty || totalDosesText.isEmpty || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and pick a time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final totalDoses = int.tryParse(totalDosesText);
    if (totalDoses == null || totalDoses <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number of doses'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_frequencyType == FrequencyType.specificDays && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<int> days = [];
    switch (_frequencyType) {
      case FrequencyType.daily:
        days = [1, 2, 3, 4, 5, 6, 7];
        break;
      case FrequencyType.weekly:
        days = [7]; // Sunday only for weekly
        break;
      case FrequencyType.specificDays:
        days = _selectedDays;
        break;
    }

    final newMedicine = MedicineModel(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      name: name,
      totalDoses: totalDoses,
      hour: _selectedTime!.hour,
      minute: _selectedTime!.minute,
      frequencyType: _frequencyType,
      selectedDays: days,
    );

    await context.read<MedicineProvider>().addMedicine(newMedicine);
    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicine Added Successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine'), elevation: 0),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MEDICINE DETAILS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Medicine Name',
                      prefixIcon: const Icon(Icons.medical_services_rounded),
                      hintText: 'Enter medicine name',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _totalDosesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Doses',
                      prefixIcon: const Icon(Icons.numbers),
                      hintText: 'e.g., 8',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<FrequencyType>(
                    value: _frequencyType,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      prefixIcon: const Icon(Icons.schedule),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    items: FrequencyType.values.map((type) {
                      String label;
                      switch (type) {
                        case FrequencyType.daily:
                          label = 'Daily';
                          break;
                        case FrequencyType.weekly:
                          label = 'Weekly (Sunday)';
                          break;
                        case FrequencyType.specificDays:
                          label = 'Specific Days';
                          break;
                      }
                      return DropdownMenuItem(value: type, child: Text(label));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _frequencyType = value!;
                        _selectedDays.clear();
                      });
                    },
                  ),
                  _buildDaySelector(),
                  const SizedBox(height: 40),
                  const Text(
                    'SCHEDULE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _selectedTime != null
                            ? Colors.teal.withOpacity(0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _selectedTime != null
                              ? Colors.teal.withOpacity(0.3)
                              : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          if (_selectedTime != null)
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedTime != null
                                  ? Colors.teal.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.access_time_filled_rounded,
                              color: _selectedTime != null
                                  ? Colors.teal
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedTime == null
                                    ? 'Set Reminder Time'
                                    : 'Scheduled For',
                                style: TextStyle(
                                  color: _selectedTime != null
                                      ? Colors.teal.shade700
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (_selectedTime != null)
                                Text(
                                  _selectedTime!.format(context),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            _selectedTime == null
                                ? Icons.add_circle_outline_rounded
                                : Icons.edit_rounded,
                            color: _selectedTime != null
                                ? Colors.teal
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveMedicine,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded),
                          SizedBox(width: 8),
                          Text(
                            'SAVE REMINDER',
                            style: TextStyle(letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
