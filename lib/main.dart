import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_quickstart/pages/account_page.dart';
import 'package:supabase_quickstart/pages/tasks_page.dart';

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  StreamSubscription<dynamic>? _authSub;

  final List<Widget> _pages = [
    const AccountPage(),
    const TasksPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Start on Login if not authenticated, otherwise show Tasks.
    _selectedIndex = supabase.auth.currentSession == null ? 0 : 1;

    // Listen to auth changes so we can switch tabs automatically.
    try {
      _authSub = supabase.auth.onAuthStateChange.listen((event) {
        final session = supabase.auth.currentSession;
        if (session != null && mounted) {
          setState(() => _selectedIndex = 1);
        } else if (session == null && mounted) {
          setState(() => _selectedIndex = 0);
        }
      });
    } catch (_) {
      // If the auth stream API is not available for some reason, ignore.
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tareas',
          ),
        ],
      ),
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
