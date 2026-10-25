
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/focus/presentation/screens/welcome_screen.dart';

class AdaptiveFocusStudioApp extends StatelessWidget {
  const AdaptiveFocusStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Focus Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
