import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility class for debouncing search operations
/// Delays execution of a function until a specified duration has passed
/// without the function being called again
class SearchDebouncer {
  final Duration delay;
  Timer? _timer;

  /// Creates a SearchDebouncer with the specified delay
  /// Default delay is 300ms as per requirements
  SearchDebouncer({this.delay = const Duration(milliseconds: 300)});

  /// Runs the provided action after the delay period
  /// Cancels any pending action if called again before delay expires
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer and cancels any pending timers
  void dispose() {
    _timer?.cancel();
  }
}
