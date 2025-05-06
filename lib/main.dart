import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme_notifier.dart';
import 'screens/home_screen.dart';
import 'screens/create_connection.dart';
import 'screens/description_screen.dart';
import 'screens/module_detail_screen.dart';
import 'screens/entry_form_screen.dart';

String apiKey = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJfaWQiOiI2N2Y2N2JmNDc1Y2E1MzI4YWZmZGY0OTAiLCJnaXZlbl9uYW1lIjpudWxsLCJmYW1pbHlfbmFtZSI6Ikphcml3YWxhIiwibmFtZSI6Im51bGwgSmFyaXdhbGEiLCJuaWNrbmFtZSI6bnVsbCwiZW1haWwiOiJqb3JkYW5nYW1pbmc0NDhAZ21haWwuY29tIn0sInNwYWNlIjoiMTEiLCJpYXQiOjE3NDQ4MjA3ODEsImV4cCI6MTc3NjM1Njc4MX0.qu3AWOzCC5rq-hadjDjSslhytt-j49q7o10Be73k_C6HdaicODk0EtEwq4xxMNEt7P76ETg98xjfVu2VeYEWYuR0mKsLXO2LsarGcFM2f__oaNeDr83ZxKPwyufjPhXwwvN2uvuIDTvJFZrh9AfxjCPO0xqVUyFR4BQbzoyaV15qbEs1hptR-VMnKfBUvHsdK6mjXk1gTFlk9bGUFW3EU5YNQU4DOvBPwCn3KKtYtd5dCcTAhRR9lS1wzZvLHo-Tni-dBUPz2hMD1pb8l8Q8Jhy_dAOBTGx68iKTWUnzl0m0KMn0Kya5Hv2StC69RErC7Qri8gD7b4v3jObTtMuYuA'; // Global API key

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: const PulseApp(),
    ),
  );
}

class PulseApp extends StatelessWidget {
  const PulseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Pulse App',

      // ====================== LIGHT THEME ======================
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
      ),

      // ====================== DARK THEME ======================
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      themeMode: themeNotifier.themeMode,
      initialRoute: '/createConnection',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/createConnection':
            return MaterialPageRoute(
                builder: (context) => const CreateConnection());
          case '/description':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => DescriptionScreen(
                appName: args['appName'],
                connectionName: args['connectionName'],
                connectionId: args['connectionId'],
                logoDark: args['logoDark'],
                apiKey: apiKey,
              ),
            );
          case '/moduleDetail':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ModuleDetailScreen(
                moduleName: args['moduleName'],
                apiKey: apiKey,
              ),
            );
          case '/entryForm':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => EntryFormScreen(
                schema: args['schema'],
                apiKey: apiKey,
                createUrl: args['createUrl'],
                editData: args['editData'],
              ),
            );
          default:
            return MaterialPageRoute(builder: (context) => const HomeScreen());
        }
      },
    );
  }
}
