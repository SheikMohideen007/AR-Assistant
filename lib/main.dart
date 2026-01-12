import 'package:ar_assistant/pages/chat_bloc.dart';
import 'package:ar_assistant/pages/chat_event.dart';
import 'package:ar_assistant/pages/chat_page.dart';
import 'package:ar_assistant/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final themeController = ThemeController();

void main() {
  runApp(const ARAssistantApp());
}

class ARAssistantApp extends StatelessWidget {
  const ARAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc()..add(AddHeaderMessageEvent()),
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, child) => MaterialApp(
          title: 'AR Assistant',
          debugShowCheckedModeBanner: false,
          theme: themeController.currentTheme,
          home: const ChatPage(),
        ),
      ),
    );
  }
}
