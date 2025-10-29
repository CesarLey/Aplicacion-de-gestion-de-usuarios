import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_quickstart/pages/account_page.dart';
import 'package:supabase_quickstart/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from a local .env file (not committed).
  // Wrap in try/catch so the app won't crash if the file is missing.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If .env is not present, continue using fallback values.
    // Print to console so you can notice during development.
    // ignore: avoid_print
    print('No .env file found or failed to load; using fallback values.');
  }

  // Helper to safely read env values: dotenv.env throws if not initialized.
  String? safeEnv(String key) {
    try {
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  // Prefer values from the environment, fallback to the constants that
  // were previously in the file if the .env file is not present.
  await Supabase.initialize(
    url: safeEnv('SUPABASE_URL') ?? 'https://kmkhyipsxuwmusuvthyp.supabase.co',
    anonKey: safeEnv('SUPABASE_ANON_KEY') ??
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtta2h5aXBzeHV3bXVzdXZ0aHlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3NDUzODMsImV4cCI6MjA3NzMyMTM4M30.H6hc8gakOP_oIHxycBqYHtDNq0GyDi3nrrL3KQRh9dg',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.green),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
      ),
      home: supabase.auth.currentSession == null
          ? const LoginPage()
          : const AccountPage(),
    );
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
