
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final reduceMotionProvider =
    AsyncNotifierProvider<ReduceMotionNotifier, bool>(
  ReduceMotionNotifier.new,
);

class ReduceMotionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool('reduce_motion') ?? false;
  }

  Future<void> setReduceMotion(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('reduce_motion', enabled);
    state = AsyncData(enabled);
  }
}
