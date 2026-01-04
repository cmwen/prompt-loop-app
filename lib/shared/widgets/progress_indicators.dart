import 'package:flutter/material.dart';
import 'package:prompt_loop/core/theme/app_colors.dart';

/// A custom progress bar widget.
class ProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final Duration animationDuration;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(height / 2);
    final bgColor =
        backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final fgColor = foregroundColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      height: height,
      decoration: BoxDecoration(color: bgColor, borderRadius: radius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: animationDuration,
                width: constraints.maxWidth * value.clamp(0.0, 1.0),
                height: height,
                decoration: BoxDecoration(color: fgColor, borderRadius: radius),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A circular progress indicator with percentage.
class CircularProgressWithLabel extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? labelStyle;
  final Widget? center;

  const CircularProgressWithLabel({
    super.key,
    required this.value,
    this.size = 80,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.foregroundColor,
    this.labelStyle,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final fgColor = foregroundColor ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: strokeWidth,
            color: bgColor,
          ),
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            color: fgColor,
            strokeCap: StrokeCap.round,
          ),
          Center(
            child:
                center ??
                Text(
                  '${(value * 100).toInt()}%',
                  style:
                      labelStyle ??
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
          ),
        ],
      ),
    );
  }
}

/// A segmented progress bar showing multiple segments.
class SegmentedProgressBar extends StatelessWidget {
  final List<ProgressSegment> segments;
  final double height;
  final double gap;

  const SegmentedProgressBar({
    super.key,
    required this.segments,
    this.height = 8,
    this.gap = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;

          return Expanded(
            flex: segment.flex,
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : gap / 2,
                right: index == segments.length - 1 ? 0 : gap / 2,
              ),
              decoration: BoxDecoration(
                color: segment.color,
                borderRadius: BorderRadius.horizontal(
                  left: index == 0 ? Radius.circular(height / 2) : Radius.zero,
                  right: index == segments.length - 1
                      ? Radius.circular(height / 2)
                      : Radius.zero,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A segment for the segmented progress bar.
class ProgressSegment {
  final Color color;
  final int flex;

  const ProgressSegment({required this.color, this.flex = 1});
}

/// A streak indicator widget.
class StreakIndicator extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  final bool isActiveToday;

  const StreakIndicator({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    required this.isActiveToday,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isActiveToday
              ? Icons.local_fire_department
              : Icons.local_fire_department_outlined,
          color: isActiveToday
              ? AppColors.warning
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '$currentStreak day${currentStreak != 1 ? 's' : ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isActiveToday
                ? AppColors.warning
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        if (bestStreak > currentStreak) ...[
          const SizedBox(width: 8),
          Text(
            '(best: $bestStreak)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
