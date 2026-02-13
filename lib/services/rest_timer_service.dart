import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RestTimerModel {
  final Duration remainingTime;
  final bool isRunning;
  final bool isCompleted;
  final Duration totalDuration;

  RestTimerModel({
    required this.remainingTime,
    required this.isRunning,
    required this.isCompleted,
    required this.totalDuration,
  });

  RestTimerModel copyWith({
    Duration? remainingTime,
    bool? isRunning,
    bool? isCompleted,
    Duration? totalDuration,
  }) {
    return RestTimerModel(
      remainingTime: remainingTime ?? this.remainingTime,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  double get progress {
    if (totalDuration.inSeconds == 0) return 0.0;
    return 1.0 - (remainingTime.inSeconds / totalDuration.inSeconds);
  }

  String get formattedTime {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class RestTimerService {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isRunning = false;
  bool _isCompleted = false;
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  RestTimerService() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> startTimer(Duration duration) async {
    _stopTimer();
    _totalDuration = duration;
    _remainingTime = duration;
    _isRunning = true;
    _isCompleted = false;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime -= const Duration(seconds: 1);
      } else {
        _completeTimer();
      }
    });
    
    _scheduleNotification(duration);
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  void resumeTimer() {
    if (!_isCompleted && _remainingTime.inSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime -= const Duration(seconds: 1);
        } else {
          _completeTimer();
        }
      });
      _isRunning = true;
    }
  }

  void skipTimer() {
    _completeTimer();
  }

  void resetTimer(Duration? newDuration) {
    _stopTimer();
    _totalDuration = newDuration ?? _totalDuration;
    _remainingTime = _totalDuration;
    _isRunning = false;
    _isCompleted = false;
  }

  void _completeTimer() {
    _stopTimer();
    _remainingTime = Duration.zero;
    _isRunning = false;
    _isCompleted = true;
    
    _showCompletionNotification();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  Future<void> _scheduleNotification(Duration duration) async {
    if (duration.inSeconds > 10) { // Only schedule if timer > 10 seconds
      await _notificationsPlugin.zonedSchedule(
        0,
        'Rest Timer Complete',
        'Your rest period is over! Time for your next set.',
        DateTime.now().add(duration),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'rest_timer_channel',
            'Rest Timer',
            channelDescription: 'Notifications for workout rest timer',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _showCompletionNotification() async {
    await _notificationsPlugin.show(
      1,
      'Rest Timer Complete',
      'Your rest period is over! Time for your next set.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rest_timer_channel',
          'Rest Timer',
          channelDescription: 'Notifications for workout rest timer',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  RestTimerModel get state => RestTimerModel(
    remainingTime: _remainingTime,
    isRunning: _isRunning,
    isCompleted: _isCompleted,
    totalDuration: _totalDuration,
  );

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

final restTimerServiceProvider = Provider<RestTimerService>((ref) {
  final service = RestTimerService();
  ref.onDispose(() => service.dispose());
  return service;
});

final restTimerStateProvider = StateProvider<RestTimerModel>((ref) {
  final service = ref.watch(restTimerServiceProvider);
  return service.state;
});