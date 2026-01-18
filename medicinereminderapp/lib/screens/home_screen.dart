import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../core/constants.dart';
import 'add_medicine_screen.dart';
import '../widgets/medicine_tile.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Notification callback for in-app popup
    NotificationService.init((response) {
      _showReminderPopup(response.payload ?? "It's time for your medicine!");
    });
  }

  void _showReminderPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Medicine Reminder',
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OKAY'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () async {
              await NotificationService.showImmediateNotification(
                id: 999,
                title: 'Test Notification',
                body: 'If you see this, notifications are working!',
              );
            },
            tooltip: 'Test Notification',
          ),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          if (provider.medicines.isEmpty) {
            return const Center(
              child: Text(
                AppConstants.noMedicinesMsg,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.medicines.length,
            itemBuilder: (context, index) {
              final medicine = provider.medicines[index];
              return MedicineTile(medicine: medicine);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
