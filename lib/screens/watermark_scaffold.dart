import 'package:flutter/material.dart';

class WatermarkScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;

  const WatermarkScaffold({super.key, required this.body, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          // Small watermark placed strictly in the bottom right corner
          Positioned(
            bottom: 12,
            right: 12,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: const Text(
                  "developed by imdomsy",
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          // Game content screen layers
          SafeArea(child: body),
        ],
      ),
    );
  }
}