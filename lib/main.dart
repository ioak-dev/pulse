import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme_notifier.dart';
import 'screens/home_screen.dart';
import 'screens/create_connection.dart';
import 'screens/description_screen.dart';
import 'screens/module_detail_screen.dart';
import 'screens/entry_form_screen.dart';

void main() {
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
              ),
            );
          case '/moduleDetail':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ModuleDetailScreen(
                moduleName: args['moduleName'],
                apiKey: args['apiKey'],
              ),
            );
          case '/entryForm':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => EntryFormScreen(
                schema: args['schema'],
                apiKey: args['apiKey'],
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
