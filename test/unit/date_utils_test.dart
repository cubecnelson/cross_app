import 'package:flutter_test/flutter_test.dart';
import 'package:cross/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    test('formatDate returns correct format', () {
      final date = DateTime(2023, 12, 25);
      expect(AppDateUtils.formatDate(date), 'Dec 25, 2023');
    });

    test('formatTime returns correct format', () {
      final time = DateTime(2023, 12, 25, 14, 30);
      expect(AppDateUtils.formatTime(time), '14:30');
    });

    test('formatDateTime returns correct format', () {
      final dateTime = DateTime(2023, 12, 25, 14, 30);
      expect(AppDateUtils.formatDateTime(dateTime), 'Dec 25, 2023 14:30');
    });

    test('formatWorkoutDate returns "Today" for today', () {
      final now = DateTime.now();
      expect(AppDateUtils.formatWorkoutDate(now), 'Today');
    });

    test('formatWorkoutDate returns "Yesterday" for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(AppDateUtils.formatWorkoutDate(yesterday), 'Yesterday');
    });

    test('formatWorkoutDate returns day name for within 7 days', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final dayName = AppDateUtils.formatWorkoutDate(threeDaysAgo);
      // Should be a day name like "Monday", "Tuesday", etc.
      expect(dayName, isNot('Today'));
      expect(dayName, isNot('Yesterday'));
      expect(dayName, isNot(contains('2023')));
    });

    test('formatDuration formats correctly for hours', () {
      final duration = Duration(hours: 2, minutes: 30, seconds: 45);
      expect(AppDateUtils.formatDuration(duration), '2h 30m');
    });

    test('formatDuration formats correctly for minutes', () {
      final duration = Duration(minutes: 45, seconds: 30);
      expect(AppDateUtils.formatDuration(duration), '45m 30s');
    });

    test('formatDuration formats correctly for seconds only', () {
      final duration = Duration(seconds: 45);
      expect(AppDateUtils.formatDuration(duration), '45s');
    });

    test('formatRestTime formats seconds correctly', () {
      expect(AppDateUtils.formatRestTime(30), '30s');
      expect(AppDateUtils.formatRestTime(90), '1m 30s');
      expect(AppDateUtils.formatRestTime(120), '2m');
    });

    test('isSameDay returns true for same day', () {
      final date1 = DateTime(2023, 12, 25, 10, 30);
      final date2 = DateTime(2023, 12, 25, 14, 45);
      expect(AppDateUtils.isSameDay(date1, date2), isTrue);
    });

    test('isSameDay returns false for different days', () {
      final date1 = DateTime(2023, 12, 25);
      final date2 = DateTime(2023, 12, 26);
      expect(AppDateUtils.isSameDay(date1, date2), isFalse);
    });

    test('getStartOfWeek returns Monday for any day in week', () {
      final wednesday = DateTime(2023, 12, 27); // Wednesday
      final startOfWeek = AppDateUtils.getStartOfWeek(wednesday);
      expect(startOfWeek.weekday, DateTime.monday);
      expect(startOfWeek.day, 25); // Dec 25, 2023 was Monday
    });

    test('getEndOfWeek returns Sunday for any day in week', () {
      final wednesday = DateTime(2023, 12, 27); // Wednesday
      final endOfWeek = AppDateUtils.getEndOfWeek(wednesday);
      expect(endOfWeek.weekday, DateTime.sunday);
      expect(endOfWeek.day, 31); // Dec 31, 2023 was Sunday
    });

    test('getDaysInWeek returns 7 days starting Monday', () {
      final wednesday = DateTime(2023, 12, 27);
      final days = AppDateUtils.getDaysInWeek(wednesday);
      expect(days.length, 7);
      expect(days[0].weekday, DateTime.monday);
      expect(days[6].weekday, DateTime.sunday);
    });
  });
}