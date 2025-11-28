import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'prof_shell.dart';
import 'occupancy_page.dart';

void main() {
  runApp(const CampusConnectApp());
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusConnect',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEEEEEE),
        primaryColor: const Color(0xFF222831),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF00ADB5),
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF222831)),
        ),
      ),
      home: const ProfShell(), // Changed from WelcomeScreen to show navigation
    );
  }
}
