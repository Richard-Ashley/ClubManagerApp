import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';

/// Stacked date display — "MON / 30 / Jun". The signature motif
/// repeated across booking-related screens.
class DateBlock extends StatelessWidget {
  const DateBlock({
    super.key,
    required this.date,
    this.size = DateBlockSize.medium,
    this.compact = false,
  });

  final DateTime date;
  final DateBlockSize size;
  final bool compact;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final dayName  = _weekdays[date.weekday - 1].toUpperCase();
    final dayNum   = date.day.toString().padLeft(2, '0');
    final monthName = _months[date.month - 1].toUpperCase();

    final (dayFontSize, numFontSize) = switch (size) {
      DateBlockSize.small  => (8.0, 14.0),
      DateBlockSize.medium => (10.0, 20.0),
      DateBlockSize.large  => (11.0, 28.0),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayName,
          style: AppTypography.eyebrow.copyWith(fontSize: dayFontSize),
        ),
        const SizedBox(height: 2),
        Text(
          dayNum,
          style: AppTypography.stat.copyWith(
            fontSize: numFontSize,
            fontFamily: 'Fraunces',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          monthName,
          style: AppTypography.eyebrow.copyWith(fontSize: dayFontSize),
        ),
      ],
    );
  }
}

enum DateBlockSize { small, medium, large }

/// Three-step progress indicator. State per step:
/// - done: filled with accent + check
/// - active: filled with primary ink + number
/// - pending: outlined
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.labels = const [],
  });

  final int totalSteps;
  final int currentStep; // 1-indexed
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 1; i <= totalSteps; i++) ...[
              _Step(
                index: i,
                state: i < currentStep
                    ? _StepState.done
                    : i == currentStep
                        ? _StepState.active
                        : _StepState.pending,
              ),
              if (i < totalSteps)
                Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: i < currentStep ? AppColors.accent : AppColors.borderStrong,
                  ),
                ),
            ],
          ],
        ),
        if (labels.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Text(
                    labels[i],
                    textAlign: i == 0
                        ? TextAlign.start
                        : i == labels.length - 1
                            ? TextAlign.end
                            : TextAlign.center,
                    style: AppTypography.meta.copyWith(
                      color: i + 1 == currentStep ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: i + 1 == currentStep ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

enum _StepState { done, active, pending }

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.state});
  final int index;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (state) {
      _StepState.done    => (AppColors.accent,     AppColors.accent,     AppColors.surface),
      _StepState.active  => (AppColors.textPrimary, AppColors.textPrimary, AppColors.surface),
      _StepState.pending => (Colors.transparent,   AppColors.borderStrong, AppColors.textSecondary),
    };

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: state == _StepState.done
          ? Icon(Icons.check, size: 13, color: fg)
          : Text(
              '$index',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: fg,
                height: 1,
              ),
            ),
    );
  }
}
