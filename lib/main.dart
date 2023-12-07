import 'package:flutter/material.dart';
import 'package:polyrythms/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PolyrythmApp());
}

class PolyrythmApp extends StatelessWidget {
  const PolyrythmApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyrythms',
      home: const SoundpoolInitializer(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'RubikMonoOne',
        primaryColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
