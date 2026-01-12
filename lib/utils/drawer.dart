import 'package:ar_assistant/api/api_client.dart';
import 'package:ar_assistant/main.dart';
import 'package:ar_assistant/services/timeout_manager.dart';
import 'package:ar_assistant/theme_controller.dart';
import 'package:flutter/material.dart';

Widget buildCustomDrawer(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = themeController.currentMode == AppThemeMode.dark;

  return Drawer(
    backgroundColor: theme.scaffoldBackgroundColor,
    child: Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E3A8A), const Color(0xFF111827)]
                  : [const Color(0xFF10B981), const Color(0xFF059669)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.account_circle_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AR Assistant',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your AI Companion',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.timer),
          title: const Text('Set Timeout Limit'),
          subtitle: const Text('Change API request timeout'),
          onTap: () async {
            Navigator.pop(context); // close drawer
            await _showTimeoutBottomSheet(context);
          },
        ),
        Expanded(child: const SizedBox()),

        SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: isDark,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (bool value) {
                    themeController.setMode(
                      value ? AppThemeMode.dark : AppThemeMode.light,
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Future<void> _showTimeoutBottomSheet(BuildContext context) async {
  var currentTimeout = await TimeoutManager.getTimeoutSeconds();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set API Timeout',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Current: ${currentTimeout}s',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              DropdownButton<int>(
                value: currentTimeout,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 30, child: Text('30 seconds')),
                  DropdownMenuItem(value: 60, child: Text('60 seconds')),
                  DropdownMenuItem(value: 75, child: Text('75 seconds')),
                  DropdownMenuItem(
                    value: 120,
                    child: Text('120 seconds (2 min)'),
                  ),
                  DropdownMenuItem(
                    value: 200,
                    child: Text('200 seconds (3+ min) (default)'),
                  ),
                ],
                onChanged: (newValue) async {
                  setModalState(() {
                    currentTimeout = newValue!;
                  });
                  if (newValue != null) {
                    await TimeoutManager.setTimeoutSeconds(newValue);
                    await TimeoutManager.applyToDio(ApiClient().dio);
                    setModalState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 2),
                        content: Text('Timeout updated to ${newValue}s'),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 32),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
