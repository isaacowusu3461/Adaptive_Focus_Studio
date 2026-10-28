
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/notifications/focus_notification_controller.dart';
import '../../../../core/notifications/focus_notification_service.dart';
import '../../domain/entities/focus_preset.dart';
import '../../domain/usecases/save_session_log.dart';

enum FocusTimerStatus {
  ready,
  running,
  paused,
  finished,
}

class FocusTimerScreen extends StatefulWidget {
  final FocusPreset preset;
  final SaveSessionLog saveSessionLog;
  final FocusNotificationController? notificationController;

  const FocusTimerScreen({
    super.key,
    required this.preset,
    required this.saveSessionLog,
    this.notificationController,
  });

  @override
  State<FocusTimerScreen> createState() =>
      _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  Timer? _ticker;
  final Stopwatch _stopwatch = Stopwatch();

  late final int _totalSeconds;
  late int _remainingSeconds;
  late final FocusNotificationController _notificationController;

  FocusTimerStatus _status = FocusTimerStatus.ready;
  bool _isSaving = false;
  bool _sessionSaved = false;
  bool _completedNaturally = false;
  bool _notificationAttempted = false;

  @override
  void initState() {
    super.initState();

    _totalSeconds = widget.preset.durationMinutes * 60;
    _remainingSeconds = _totalSeconds;

    _notificationController = widget.notificationController ??
        FocusNotificationController(
          LocalFocusNotificationService(),
        );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  int get _completedSeconds {
    final elapsed = _stopwatch.elapsed.inSeconds;
    return elapsed.clamp(0, _totalSeconds);
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get _statusText {
    switch (_status) {
      case FocusTimerStatus.ready:
        return 'Ready';
      case FocusTimerStatus.running:
        return 'Running';
      case FocusTimerStatus.paused:
        return 'Paused';
      case FocusTimerStatus.finished:
        return 'Finished';
    }
  }

  void _updateRemainingTime() {
    if (!mounted || _status != FocusTimerStatus.running) {
      return;
    }

    final remaining = _totalSeconds - _completedSeconds;

    if (remaining <= 0) {
      _stopwatch.stop();
      _ticker?.cancel();

      setState(() {
        _remainingSeconds = 0;
        _status = FocusTimerStatus.finished;
        _completedNaturally = true;
      });

      _saveSession('completed');
      return;
    }

    setState(() {
      _remainingSeconds = remaining;
    });
  }

  void _startTimer() {
    if (_status != FocusTimerStatus.ready) {
      return;
    }

    _stopwatch.start();

    setState(() {
      _status = FocusTimerStatus.running;
    });

    _ticker = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _updateRemainingTime(),
    );
  }

  void _pauseTimer() {
    if (_status != FocusTimerStatus.running) {
      return;
    }

    _stopwatch.stop();
    _ticker?.cancel();

    setState(() {
      _status = FocusTimerStatus.paused;
    });
  }

  void _resumeTimer() {
    if (_status != FocusTimerStatus.paused) {
      return;
    }

    _stopwatch.start();

    setState(() {
      _status = FocusTimerStatus.running;
    });

    _ticker = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _updateRemainingTime(),
    );
  }

  Future<void> _finishTimer() async {
    if (_status != FocusTimerStatus.running &&
        _status != FocusTimerStatus.paused) {
      return;
    }

    _stopwatch.stop();
    _ticker?.cancel();

    setState(() {
      _remainingSeconds =
          (_totalSeconds - _completedSeconds).clamp(
        0,
        _totalSeconds,
      );
      _status = FocusTimerStatus.finished;
      _completedNaturally = false;
    });

    await _saveSession(
      _remainingSeconds == 0 ? 'completed' : 'partial',
    );
  }

  void _resetTimer() {
    if (_isSaving) {
      return;
    }

    _ticker?.cancel();
    _stopwatch
      ..stop()
      ..reset();

    setState(() {
      _remainingSeconds = _totalSeconds;
      _status = FocusTimerStatus.ready;
      _sessionSaved = false;
      _completedNaturally = false;
      _notificationAttempted = false;
    });
  }

  Future<void> _sendCompletionNotification(
    String status,
  ) async {
    if (_notificationAttempted) {
      return;
    }

    if (!_completedNaturally || status != 'completed') {
      return;
    }

    _notificationAttempted = true;

    try {
      await _notificationController.onSessionSaved(
        presetName: widget.preset.name,
        completedNaturally: _completedNaturally,
        status: status,
      );
    } catch (error) {
      debugPrint('Unable to show focus notification: $error');
    }
  }

  Future<void> _saveSession(String status) async {
    if (_isSaving || _sessionSaved) {
      return;
    }

    final presetId = widget.preset.id;

    if (presetId == null) {
      _showMessage('Cannot save a preset without an ID.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.saveSessionLog(
        presetId: presetId,
        date: DateTime.now(),
        completedSeconds: status == 'completed'
            ? _totalSeconds
            : _completedSeconds,
        status: status,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _sessionSaved = true;
      });

      _showMessage('Study session saved successfully.');

      await _sendCompletionNotification(status);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to save session. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds == 0
        ? 0.0
        : _completedSeconds / _totalSeconds;

    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Focus Session'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.preset.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mood: ${widget.preset.moodTag}',
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 220,
                    width: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 220,
                          width: 220,
                          child: CircularProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            strokeWidth: 10,
                            backgroundColor: Colors.black12,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formattedTime,
                              key: const ValueKey('timer_display'),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _statusText,
                              key: const ValueKey('timer_status'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton(
                        onPressed: _status == FocusTimerStatus.ready
                            ? _startTimer
                            : null,
                        child: const Text('Start'),
                      ),
                      ElevatedButton(
                        onPressed: _status == FocusTimerStatus.running
                            ? _pauseTimer
                            : null,
                        child: const Text('Pause'),
                      ),
                      ElevatedButton(
                        onPressed: _status == FocusTimerStatus.paused
                            ? _resumeTimer
                            : null,
                        child: const Text('Resume'),
                      ),
                      OutlinedButton(
                        onPressed: (_status == FocusTimerStatus.running ||
                                _status == FocusTimerStatus.paused)
                            ? _finishTimer
                            : null,
                        child: const Text('Finish'),
                      ),
                      OutlinedButton(
                        onPressed: _isSaving ? null : _resetTimer,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Planned: ${widget.preset.durationMinutes} minutes',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Completed: ${_completedSeconds ~/ 60} minutes '
                            '${_completedSeconds % 60} seconds',
                          ),
                          if (_isSaving) ...[
                            const SizedBox(height: 12),
                            const CircularProgressIndicator(),
                          ],
                          if (_status == FocusTimerStatus.finished &&
                              !_sessionSaved &&
                              !_isSaving) ...[
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _saveSession(
                                _remainingSeconds == 0
                                    ? 'completed'
                                    : 'partial',
                              ),
                              child: const Text('Retry Save'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
