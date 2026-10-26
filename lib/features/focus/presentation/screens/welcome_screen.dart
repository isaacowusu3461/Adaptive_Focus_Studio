
import 'package:flutter/material.dart';

import '../providers/focus_dependencies.dart';
import 'main_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final FocusDependencies dependencies;

  const WelcomeScreen({
    super.key,
    required this.dependencies,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Focus Studio'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 90,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Adaptive Focus Studio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Organize your study sessions, stay focused, '
                  'and track your progress.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(
                          dependencies: dependencies,
                        ),
                      ),
                    );
                  },
                  child: const Text('Get Started'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
