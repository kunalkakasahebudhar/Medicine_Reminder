import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/medicine_provider.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    print('Main: Initializing Hive...');
    // Initialize Hive
    await HiveService.init();
    print('Main: Hive initialized.');

    print('Main: Initializing Notifications...');
    // Initialize Notifications
    await NotificationService.init((response) {
      if (response.payload != null || response.id != null) {
        // Logic for handling notification click
      }
    });
    print('Main: Notifications initialized.');

    print('Main: Requesting permissions...');
    // Background permissions
    await NotificationService.requestPermissions();
    print('Main: Permissions requested.');
  } catch (e) {
    print('Main: Initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicineProvider(HiveService())),
      ],
      child: MaterialApp(
        title: 'Medicine Reminder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          // Global error handling UI
          ErrorWidget.builder = (details) {
            return Scaffold(
              body: Center(
                child: Text('Something went wrong: ${details.exception}'),
              ),
            );
          };
          return child!;
        },
        home: const HomeScreen(),
      ),
    );
  }
}
