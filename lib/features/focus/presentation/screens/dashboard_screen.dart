
import 'package:flutter/material.dart';

import 'preset_form_screen.dart';
import 'focus_timer_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Focus Studio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Study Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Completed Sessions: 0'),
                  SizedBox(height: 8),
                  Text('Average Duration: 0 minutes'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Focus Presets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PresetFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: 'All',
            decoration: const InputDecoration(
              labelText: 'Mood Filter',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'All',
                child: Text('All'),
              ),
              DropdownMenuItem(
                value: 'Focused',
                child: Text('Focused'),
              ),
              DropdownMenuItem(
                value: 'Relaxed',
                child: Text('Relaxed'),
              ),
              DropdownMenuItem(
                value: 'Motivated',
                child: Text('Motivated'),
              ),
            ],
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Example Study Preset'),
              subtitle: const Text(
                'Mood: Focused | Duration: 25 minutes',
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const FocusTimerScreen(),
                    ),
                  );
                },
                child: const Text('Start'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Session Scout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggested Duration: 25 minutes',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is a temporary suggestion. '
                    'Personalized recommendations will be '
                    'available soon.',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Suggestion feature coming soon!',
                              ),
                            ),
                          );
                        },
                        child: const Text('Apply'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Not now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
