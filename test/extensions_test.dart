import 'package:club_manager_app/shared/extensions/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('String.capitalize', () {
    test('upper-cases the first letter and lower-cases the rest', () {
      expect('hELLO'.capitalize, 'Hello');
      expect('admin'.capitalize, 'Admin');
    });

    test('leaves an empty string alone', () {
      expect(''.capitalize, '');
    });
  });

  group('String.toDisplayDate', () {
    test('formats an ISO date', () {
      expect('2026-11-27'.toDisplayDate(), 'Nov 27, 2026');
    });

    test('returns the input unchanged when it is not a date', () {
      expect('not a date'.toDisplayDate(), 'not a date');
    });
  });

  group('DateTime extensions', () {
    final date = DateTime(2026, 11, 27, 9, 5);

    test('toApiDate uses yyyy-MM-dd', () {
      expect(date.toApiDate(), '2026-11-27');
    });

    test('toDisplayDate uses MMM d, yyyy', () {
      expect(date.toDisplayDate(), 'Nov 27, 2026');
    });

    test('toDisplayDateTime adds a zero-padded 24-hour time', () {
      expect(date.toDisplayDateTime(), 'Nov 27, 2026 · 09:05');
    });
  });
}
