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
            // Styled Impostor Hooded Man Identity Layout
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Outer Hood Contour Structure
                  const Icon(
                    Icons.keyboard_arrow_up, 
                    size: 110, 
                    color: Colors.blueGrey,
                  ),
                  // Shaded Head Core Faceplate
                  Positioned(
                    top: 28,
                    child: Icon(
                      Icons.person, 
                      size: 64, 
                      color: Colors.grey[800],
                    ),
                  ),
                  // Masked Eyes Silhouette Accent
                  Positioned(
                    top: 44,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 4, color: Colors.redAccent),
                        const SizedBox(width: 12),
                        Container(width: 8, height: 4, color: Colors.redAccent),
                      ],
                    ),
                  ),
                ],
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