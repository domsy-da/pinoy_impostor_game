import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/game_provider.dart';
import 'screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const PinoyImpostorApp(),
    ),
  );
}

class PinoyImpostorApp extends StatelessWidget {
  const PinoyImpostorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Pinoy Impostor Game',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const MainMenuScreen(),
    );
  }
}