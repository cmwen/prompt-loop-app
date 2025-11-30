import 'package:flutter/material.dart';
import 'package:deliberate_practice_app/core/theme/app_colors.dart';

/// A styled card widget for the app.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
  });
  
  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? 0,
      color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }
    
    return card;
  }
}

/// A skill card showing skill name, level, and progress.
class SkillCard extends StatelessWidget {
  final String name;
  final String level;
  final double progress;
  final VoidCallback? onTap;
  final Widget? trailing;
  
  const SkillCard({
    super.key,
    required this.name,
    required this.level,
    required this.progress,
    this.onTap,
    this.trailing,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(
            value: progress,
            height: 8,
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}% mastered',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A task card showing task details.
class TaskCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? difficulty;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  
  const TaskCard({
    super.key,
    required this.title,
    this.subtitle,
    this.difficulty,
    this.isCompleted = false,
    this.onTap,
    this.onComplete,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: onComplete != null ? (_) => onComplete!() : null,
            shape: const CircleBorder(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted 
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (difficulty != null) ...[
            const SizedBox(width: 8),
            DifficultyIndicator(difficulty: difficulty!),
          ],
        ],
      ),
    );
  }
}

/// A difficulty indicator showing dots based on difficulty level.
class DifficultyIndicator extends StatelessWidget {
  final int difficulty;
  final int maxDifficulty;
  
  const DifficultyIndicator({
    super.key,
    required this.difficulty,
    this.maxDifficulty = 10,
  });
  
  @override
  Widget build(BuildContext context) {
    final normalizedDifficulty = (difficulty / maxDifficulty * 5).round().clamp(1, 5);
    final color = _getDifficultyColor(normalizedDifficulty);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < normalizedDifficulty;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? color : color.withOpacity(0.2),
          ),
        );
      }),
    );
  }
  
  Color _getDifficultyColor(int normalized) {
    if (normalized <= 2) return AppColors.success;
    if (normalized <= 4) return AppColors.warning;
    return AppColors.error;
  }
}
