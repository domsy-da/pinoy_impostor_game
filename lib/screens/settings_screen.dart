import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../providers/game_provider.dart';
import '../services/database_helper.dart'; // Added database helper import
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

// Updated dialog logic handling the local reset code option
  void _showAdminPackageDialog(BuildContext context) {
    final TextEditingController passcodeController = TextEditingController();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Load Word Package"),
          content: TextField(
            controller: passcodeController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Secret Passcode",
              hintText: "Enter expansion package code",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String inputCode = passcodeController.text.trim();
                String targetUrl = "";
                bool isReset = false;

                if (inputCode == "imdomsy-pig") {
                  targetUrl = "https://pastebin.com/raw/5pTDsprH";
                } else if (inputCode == "imdomsy-200") {
                  targetUrl = "https://pastebin.com/raw/zU50qr0n";
                } else if (inputCode == "pig-doms-300") {
                  targetUrl = "https://pastebin.com/raw/EFTBjPGK";
                } else if (inputCode == "imdomsy-reset") {
                  isReset = true;
                }

                Navigator.pop(context);
                bool success = false;

                if (isReset) {
                  // Hard resets the system table back to the default words.json file layout
                  success = await DatabaseHelper.instance.resetToDefaultLocalWords();
                } else if (targetUrl.isNotEmpty) {
                  success = await DatabaseHelper.instance.fetchOnlineWordsPackage(targetUrl);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid Passcode!"), backgroundColor: Colors.red),
                    );
                  }
                  return;
                }

                if (success) {
                  await gameProvider.refreshDbWordCount();
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? (isReset ? "Reset successful! 200 default words restored." : "Success! New bundle installed.") 
                        : "Operation failed! Check connection."),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);

    // Dynamic text color to look correct on both Light and Dark mode options
    final TextStyle creditStyle = TextStyle(
      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
      fontSize: 14,
    );

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
                  // Replaced standard Text here with Text.rich to isolate your double click target
                  Text.rich(
                    TextSpan(
                      style: creditStyle,
                      children: [
                        const TextSpan(text: "This app is developed by "),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onDoubleTap: () => _showAdminPackageDialog(context),
                            child: Text(
                              "Domingo",
                              style: creditStyle.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const TextSpan(text: " Jr. Q. Agoncillo."),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
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