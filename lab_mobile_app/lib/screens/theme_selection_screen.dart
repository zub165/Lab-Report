import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Selection'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildThemeCard(
                context,
                'Light Theme',
                'Clean and bright interface',
                AppTheme.light,
                themeProvider.currentTheme == AppTheme.light,
                Colors.blue,
                Icons.light_mode,
              ),
              const SizedBox(height: 16),
              _buildThemeCard(
                context,
                'Dark Theme',
                'Easy on the eyes in low light',
                AppTheme.dark,
                themeProvider.currentTheme == AppTheme.dark,
                Colors.grey[800]!,
                Icons.dark_mode,
              ),
              const SizedBox(height: 16),
              _buildThemeCard(
                context,
                'Blue Theme',
                'Professional medical blue',
                AppTheme.blue,
                themeProvider.currentTheme == AppTheme.blue,
                Colors.blue[700]!,
                Icons.medical_services,
              ),
              const SizedBox(height: 16),
              _buildThemeCard(
                context,
                'Green Theme',
                'Natural and calming green',
                AppTheme.green,
                themeProvider.currentTheme == AppTheme.green,
                Colors.green[700]!,
                Icons.nature,
              ),
              const SizedBox(height: 16),
              _buildThemeCard(
                context,
                'Purple Theme',
                'Modern and elegant purple',
                AppTheme.purple,
                themeProvider.currentTheme == AppTheme.purple,
                Colors.purple[700]!,
                Icons.palette,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    String title,
    String description,
    AppTheme theme,
    bool isSelected,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Provider.of<ThemeProvider>(context, listen: false).setTheme(theme);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Theme changed to $title'),
              backgroundColor: color,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
