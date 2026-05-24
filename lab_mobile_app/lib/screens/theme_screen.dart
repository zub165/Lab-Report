import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Theme'),
        centerTitle: true,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: themeProvider.availableThemes.length,
            itemBuilder: (context, index) {
              final theme = themeProvider.availableThemes[index];
              final isSelected = themeProvider.currentTheme == theme;
              final accent = ThemeProvider.swatchColor(theme);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: isSelected ? 4 : 2,
                color: isSelected ? accent.withValues(alpha: 0.1) : null,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                  title: Text(
                    ThemeProvider.displayName(theme),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? accent : null,
                    ),
                  ),
                  subtitle: Text(
                    '${ThemeProvider.displayName(theme)} theme for the app',
                    style: TextStyle(
                      color: isSelected ? accent.withValues(alpha: 0.7) : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: accent,
                        )
                      : null,
                  onTap: () {
                    themeProvider.setTheme(theme);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Theme changed to ${ThemeProvider.displayName(theme)}'),
                        backgroundColor: accent,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
