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
  final _doseController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
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

  void _saveMedicine() {
    final name = _nameController.text.trim();
    final dose = _doseController.text.trim();

    if (name.isEmpty || dose.isEmpty || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and pick a time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newMedicine = MedicineModel(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      name: name,
      dose: dose,
      hour: _selectedTime!.hour,
      minute: _selectedTime!.minute,
    );

    context.read<MedicineProvider>().addMedicine(newMedicine);
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
      appBar: AppBar(title: const Text('Add Medicine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                prefixIcon: Icon(Icons.medical_services),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _doseController,
              decoration: const InputDecoration(
                labelText: 'Dose (e.g., 1 tablet)',
                prefixIcon: Icon(Icons.opacity),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: Text(
                _selectedTime == null
                    ? 'Pick Scheduled Time'
                    : 'Time: ${_selectedTime!.format(context)}',
              ),
              leading: const Icon(Icons.access_time),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _pickTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveMedicine,
                child: const Text('SAVE MEDICINE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
