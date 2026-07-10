import 'package:flutter/material.dart';
import 'watermark_scaffold.dart';
import 'settings_screen.dart';
import 'player_setup_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WatermarkScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // NEW: Brand logo rendering engine replacing old manual icon shape stacks
            Center(
              child: Image.asset(
                'assets/images/pig_logo.png',
                width: 180,  // Perfectly tuned dimensions for standard smartphone viewports
                height: 180, 
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback title card if image files are unindexed in assets
                  return const Text(
                    "Pinoy Impostor Game",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Pinoy Impostor Game",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlayerSetupScreen()),
                );
              },
              child: const Text("Start Game", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings, size: 32),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}