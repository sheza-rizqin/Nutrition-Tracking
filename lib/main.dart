import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'screens/home_screen.dart';
import 'screens/maternal_risk_screen.dart'; 

import 'database/database_helper.dart';
import 'database/web_database.dart';
import 'database/sync_service.dart';
import 'utils/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalizationService.instance.init();

  if (kIsWeb) {
    await WebDatabase.init();
  } else {
    await DatabaseHelper.instance.database;

    SyncService.instance.init();
  }

  runApp(
    ListenableBuilder(
      listenable: LocalizationService.instance,
      builder: (context, _) => const NutriTrackApp(),
    ),
  );
}

class NutriTrackApp extends StatelessWidget {
  const NutriTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriTrack',
      debugShowCheckedModeBanner: false,
      locale: LocalizationService.instance.locale,
      supportedLocales: LocalizationService.supportedLocales,

      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      routes: {
        '/maternal-risk': (context) => MaternalRiskScreen(),
      },

      home: const HomeScreen(),
    );
  }
}
