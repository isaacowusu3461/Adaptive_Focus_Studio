
import 'package:flutter/material.dart';

import '../../domain/entities/focus_preset.dart';

class FocusTimerScreen extends StatelessWidget {
  final FocusPreset preset;

  const FocusTimerScreen({
    super.key,
    required this.preset,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = preset.durationMinutes.toString().padLeft(
      2,
      '0',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Session'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  preset.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '$minutes:00',
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Ready'),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Start / Pause'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Resume'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Finish'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Planned: ${preset.durationMinutes} minutes',
                        ),
                        const SizedBox(height: 8),
                        const Text('Completed: 0 minutes'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
