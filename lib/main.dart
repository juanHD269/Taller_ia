import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  // Inicializar Supabase con variables de entorno
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    // No interrumpimos el arranque si faltan, pero la UI mostrará un aviso.
    debugPrint('⚠️ Falta SUPABASE_URL o SUPABASE_ANON_KEY en .env');
  } else {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  runApp(const OchoApp());
}

class OchoApp extends StatelessWidget {
  const OchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caso de Estudio - Tutor IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

/// Puerta de autenticación: si hay sesión, muestra Home; si no, Login.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Session? _session;
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();
    // Leer sesión actual (si Supabase está inicializado)
    try {
      _session = Supabase.instance.client.auth.currentSession;
      _sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        setState(() => _session = event.session);
      });
    } catch (_) {
      // Si no está inicializado, caeremos a Login igualmente.
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si faltan las variables de entorno de Supabase, avisar.
    final missingEnv = (dotenv.env['SUPABASE_URL'] ?? '').isEmpty ||
        (dotenv.env['SUPABASE_ANON_KEY'] ?? '').isEmpty;

    if (missingEnv) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Configura SUPABASE_URL y SUPABASE_ANON_KEY en .env para habilitar login.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return _session == null ? const LoginScreen() : const HomeScreen();
  }
}
