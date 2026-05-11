import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/trading_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const OilCfdSignalsApp());
}

class OilCfdSignalsApp extends StatelessWidget {
  const OilCfdSignalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TradingProvider()),
      ],
      child: MaterialApp(
        title: 'Oil CFD Signals',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blueAccent,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          cardColor: const Color(0xFF1E293B),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F172A),
            elevation: 0,
          ),
          colorScheme: const ColorScheme.dark(
            primary: Colors.blueAccent,
            secondary: Colors.cyanAccent,
            surface: Color(0xFF1E293B),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
