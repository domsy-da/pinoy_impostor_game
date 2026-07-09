import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../providers/game_provider.dart';
import 'watermark_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).refreshDbWordCount();
    });
  }

  Future<void> _launchPortfolio() async {
    final Uri url = Uri.parse('https://domingoagoncillo.site.je');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);

    return WatermarkScaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Dark Mode", style: TextStyle(fontSize: 18)),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              "Words inside DB: ${gameProvider.dbWordCount}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  const Text(
                    "This app is developed by Domingo Jr. Q. Agoncillo.",
                    textAlign: TextAlign.center,
                  ),
                  InkWell(
                    onTap: _launchPortfolio,
                    child: const Text(
                      "Portfolio link: domingoagoncillo.site.je",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}