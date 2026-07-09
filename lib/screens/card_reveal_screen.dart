import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'watermark_scaffold.dart';

class CardRevealScreen extends StatefulWidget {
  const CardRevealScreen({super.key});

  @override
  State<CardRevealScreen> createState() => _CardRevealScreenState();
}

class _CardRevealScreenState extends State<CardRevealScreen> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey _cardKey = GlobalKey(); // GlobalKey to track the card container's exact area

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Logic to determine if the moving touch coordinate is inside the card box bounds
  void _checkTouchBoundary(Offset globalPosition) {
    final RenderBox? renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset localPosition = renderBox.globalToLocal(globalPosition);
    final Size size = renderBox.size;

    // Check if the current finger coordinates fall within the container width and height
    final bool isInside = localPosition.dx >= 0 &&
        localPosition.dx <= size.width &&
        localPosition.dy >= 0 &&
        localPosition.dy <= size.height;

    if (isInside) {
      if (!_isPressed) {
        setState(() => _isPressed = true);
      }
    } else {
      if (_isPressed) {
        setState(() => _isPressed = false); // Hide only when it leaves the card bounds
      }
    }
  }

  void _handleNextPlayer(GameProvider gameProvider) {
    if (gameProvider.currentPlayerIndex + 1 < gameProvider.playerCount) {
      _animationController.reverse().then((_) {
        gameProvider.advanceToNextPlayer();
        _animationController.forward();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All cards viewed! Start your discussion.')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final int displayIndex = gameProvider.currentPlayerIndex;
    final String roleText = gameProvider.getPlayerRoleString(displayIndex);

    return WatermarkScaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Player ${displayIndex + 1}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Hold card to see your role instantly",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              // Custom boundary gesture layer
              GestureDetector(
                onTapDown: (details) {
                  setState(() => _isPressed = true);
                  gameProvider.markCardAsViewed();
                },
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                
                // Track dragging movement accurately
                onPanUpdate: (details) => _checkTouchBoundary(details.globalPosition),
                onPanEnd: (_) => setState(() => _isPressed = false),
                
                child: Container(
                  key: _cardKey, // Linked boundary reference key
                  height: 280,
                  decoration: BoxDecoration(
                    color: _isPressed 
                        ? (roleText.contains("impostor") ? Colors.red[800] : Colors.teal[600])
                        : Colors.blueGrey[400],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _isPressed ? roleText : "HOLD TO REVEAL",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _isPressed ? 22 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: _isPressed ? 0.5 : 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: gameProvider.hasViewedCard ? () => _handleNextPlayer(gameProvider) : null,
                child: Text(
                  displayIndex + 1 < gameProvider.playerCount ? "Next" : "Finish",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}