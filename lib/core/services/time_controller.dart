import 'package:flutter/material.dart';

class TimeController extends ChangeNotifier {
  DateTime _currentTime;
  bool _isPaused = false;
  double _timeScale = 1.0; // Days per second

  TimeController({DateTime? startTime})
      : _currentTime = startTime ?? DateTime.now();

  DateTime get currentTime => _currentTime;
  bool get isPaused => _isPaused;
  double get timeScale => _timeScale;

  void setTime(DateTime time) {
    _currentTime = time;
    notifyListeners();
  }

  void setPaused(bool paused) {
    _isPaused = paused;
    notifyListeners();
  }

  void setTimeScale(double scale) {
    _timeScale = scale;
    notifyListeners();
  }

  void advanceTime(double deltaSeconds) {
    if (_isPaused) return;

    final daysPassed = _timeScale * deltaSeconds;
    _currentTime = _currentTime.add(
      Duration(milliseconds: (daysPassed * 24 * 60 * 60 * 1000).toInt()),
    );
    notifyListeners();
  }
}
