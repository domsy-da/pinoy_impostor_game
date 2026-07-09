  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'watermark_scaffold.dart';
import 'card_reveal_screen.dart';

class PlayerSetupScreen extends StatelessWidget {
  const PlayerSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return WatermarkScaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "How many players?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 48),
                  onPressed: gameProvider.decrementPlayer,
                ),
                const SizedBox(width: 24),
                Text(
                  "${gameProvider.playerCount}",
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 48),
                  onPressed: gameProvider.incrementPlayer,
                ),
              ],
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () async {
                await gameProvider.setupNewGame();
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CardRevealScreen()),
                  );
                }
              },
              child: const Text("Start Game", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}