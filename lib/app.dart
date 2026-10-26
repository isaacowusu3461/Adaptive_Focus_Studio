
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/focus/presentation/providers/focus_dependencies.dart';
import 'features/focus/presentation/screens/welcome_screen.dart';

class AdaptiveFocusStudioApp extends StatefulWidget {
  final FocusDependencies? dependencies;

  const AdaptiveFocusStudioApp({
    super.key,
    this.dependencies,
  });

  @override
  State<AdaptiveFocusStudioApp> createState() =>
      _AdaptiveFocusStudioAppState();
}

class _AdaptiveFocusStudioAppState
    extends State<AdaptiveFocusStudioApp> {
  late final FocusDependencies _dependencies;

  @override
  void initState() {
    super.initState();
    _dependencies = widget.dependencies ?? FocusDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Focus Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: WelcomeScreen(
        dependencies: _dependencies,
      ),
    );
  }
}
