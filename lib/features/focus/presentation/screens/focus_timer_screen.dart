
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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

  // I use a Stopwatch to track the actual time spent studying
  // instead of relying on how often the timer callback runs.
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

  Color get _statusColor {
    switch (_status) {
      case FocusTimerStatus.ready:
        return AppTheme.primaryColor;
      case FocusTimerStatus.running:
        return AppTheme.secondaryColor;
      case FocusTimerStatus.paused:
        return const Color(0xFFD97706);
      case FocusTimerStatus.finished:
        return AppTheme.primaryColor;
    }
  }

  // The timer checks the elapsed time regularly and updates
  // the screen. When time runs out, I save it as completed.
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

  // Pausing stops both the Stopwatch and the periodic timer,
  // but keeps the elapsed time so the user can resume later.
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

  // If a user finishes early, I still save the time they
  // actually studied instead of counting the full duration.
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

  // I only send the completion notification when the timer
  // reaches zero naturally, not when a session ends early.
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

  // I check these flags before saving so the same study
  // session is not accidentally recorded more than once.
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

  Widget _timerButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/focus_timer.png',
                      height: 110,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.self_improvement,
                          size: 70,
                          color: AppTheme.secondaryColor,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.preset.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Chip(
                      avatar: const Icon(
                        Icons.local_offer_outlined,
                        size: 18,
                        color: AppTheme.secondaryColor,
                      ),
                      label: Text(widget.preset.moodTag),
                      backgroundColor: const Color(0xFFDFF7F3),
                      side: BorderSide.none,
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: SizedBox(
                        height: 230,
                        width: 230,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 230,
                              width: 230,
                              child: CircularProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                strokeWidth: 12,
                                strokeCap: StrokeCap.round,
                                color: AppTheme.secondaryColor,
                                backgroundColor:
                                    const Color(0xFFD1FAE5),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formattedTime,
                                  key: const ValueKey('timer_display'),
                                  style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor.withValues(
                                      alpha: 0.10,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _statusText,
                                    key: const ValueKey('timer_status'),
                                    style: TextStyle(
                                      color: _statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _timerButton(
                          label: 'Start',
                          icon: Icons.play_arrow,
                          color: AppTheme.primaryColor,
                          onPressed:
                              _status == FocusTimerStatus.ready
                                  ? _startTimer
                                  : null,
                        ),
                        _timerButton(
                          label: 'Pause',
                          icon: Icons.pause,
                          color: const Color(0xFFD97706),
                          onPressed:
                              _status == FocusTimerStatus.running
                                  ? _pauseTimer
                                  : null,
                        ),
                        _timerButton(
                          label: 'Resume',
                          icon: Icons.play_circle_outline,
                          color: AppTheme.secondaryColor,
                          onPressed:
                              _status == FocusTimerStatus.paused
                                  ? _resumeTimer
                                  : null,
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.secondaryColor,
                            side: const BorderSide(
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          onPressed:
                              (_status == FocusTimerStatus.running ||
                                      _status == FocusTimerStatus.paused)
                                  ? _finishTimer
                                  : null,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Finish'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isSaving ? null : _resetTimer,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'Session Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.event_note,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Planned: '
                                    '${widget.preset.durationMinutes} minutes',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: AppTheme.secondaryColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Completed: '
                                    '${_completedSeconds ~/ 60} minutes '
                                    '${_completedSeconds % 60} seconds',
                                  ),
                                ),
                              ],
                            ),
                            if (_isSaving) ...[
                              const SizedBox(height: 16),
                              const CircularProgressIndicator(),
                            ],
                            if (_status == FocusTimerStatus.finished &&
                                !_sessionSaved &&
                                !_isSaving) ...[
                              const SizedBox(height: 16),
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
      ),
    );
  }
}
