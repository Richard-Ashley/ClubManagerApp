import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String toDisplayDate() {
    try {
      final date = DateTime.parse(this);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return this;
    }
  }
}

extension DateTimeExtensions on DateTime {
  String toApiDate() => DateFormat('yyyy-MM-dd').format(this);
  String toDisplayDate() => DateFormat('MMM d, yyyy').format(this);
  String toDisplayDateTime() => DateFormat('MMM d, yyyy · HH:mm').format(this);
}

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.of(this).size;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showErrorSnackBar(String message) => showSnackBar(message, isError: true);
}
