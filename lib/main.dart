import 'package:flutter/material.dart';
import 'package:notes_app/services/notification_service.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/home_screen.dart';

void main() async{
    // Initialize FFI
  // sqfliteFfiInit();
  // Use ffi factory for desktop
  // databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await NotificationService.scheduleNotification(
    id: 1,
    title: 'Test Notification',
    body: 'Triggered after 5 seconds',
    scheduledTime: DateTime.now().add(Duration(seconds: 5)),
  );

  runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(),
    );
  }
}
