// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'i18n/custom_localizations_delegate.dart';
import 'screens/video_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print("Firebase Initialized");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    print("MyApp build method called");
    return MaterialApp(
      title: 'Video App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        //  visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14), // Ajustado para 14
          labelLarge: TextStyle(fontSize: 14), // Ajustado para 14
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white), // Ajustado para 20
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 14), // Ajustado para 14
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(fontSize: 14), // Ajustado para 14
        ),
      ),
      localizationsDelegates: const [
        CustomLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
        Locale('es', 'MX'),
      ],
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: VideoListScreen(), // Inicialize direto para VideoListScreen
    );
  }
}
