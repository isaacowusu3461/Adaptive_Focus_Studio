
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/focus/presentation/providers/focus_dependencies.dart';
import 'features/focus/presentation/providers/focus_providers.dart';
import 'features/focus/presentation/screens/welcome_screen.dart';

class AdaptiveFocusStudioApp extends StatelessWidget {
  final FocusDependencies? dependencies;

  const AdaptiveFocusStudioApp({
    super.key,
    this.dependencies,
  });

  @override
  Widget build(BuildContext context) {
    final focusDependencies = dependencies ?? FocusDependencies();

    return ProviderScope(
      overrides: [
        focusDependenciesProvider.overrideWithValue(
          focusDependencies,
        ),
      ],
      child: MaterialApp(
        title: 'Adaptive Focus Studio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: WelcomeScreen(
          dependencies: focusDependencies,
        ),
      ),
    );
  }
}
