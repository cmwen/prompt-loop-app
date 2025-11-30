import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_loop/core/router/app_router.dart';
import 'package:prompt_loop/domain/entities/purpose.dart';
import 'package:prompt_loop/features/purpose/providers/purpose_provider.dart';
import 'package:prompt_loop/features/skills/providers/skills_provider.dart';
import 'package:prompt_loop/shared/widgets/app_card.dart';
import 'package:prompt_loop/shared/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

/// Screen displaying all purposes organized by skill.
class PurposesListScreen extends ConsumerWidget {
  const PurposesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Purposes'),
      ),
      body: skills.when(
        data: (skillList) {
          if (skillList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No skills yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a skill first to connect it to your purpose.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go(AppPaths.skills),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Skill'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: skillList.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Your purposes drive your practice. Review them often to stay motivated.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              final skill = skillList[index - 1];
              return _PurposeCard(
                skillId: skill.id!,
                skillName: skill.name,
              );
            },
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _PurposeCard extends ConsumerWidget {
  final int skillId;
  final String skillName;

  const _PurposeCard({
    required this.skillId,
    required this.skillName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purposeAsync = ref.watch(purposeBySkillProvider(skillId));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: purposeAsync.when(
        data: (purpose) {
          if (purpose == null) {
            return _buildNoPurposeCard(context);
          }
          return _buildPurposeCard(context, ref, purpose);
        },
        loading: () => AppCard(
          child: ListTile(
            leading: const CircularProgressIndicator(strokeWidth: 2),
            title: Text(skillName),
          ),
        ),
        error: (e, _) => AppCard(
          child: ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: Text(skillName),
            subtitle: Text('Error: $e'),
          ),
        ),
      ),
    );
  }

  Widget _buildNoPurposeCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  skillName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'No purpose connected to this skill yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(
                '${AppPaths.purposeEdit}?skillId=$skillId',
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Purpose'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeCard(BuildContext context, WidgetRef ref, Purpose purpose) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  skillName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withAlpha(51),
              ),
            ),
            child: Text(
              '"${purpose.statement}"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Chip(
                label: Text(_getCategoryLabel(purpose.category)),
                visualDensity: VisualDensity.compact,
              ),
              const Spacer(),
              Text(
                'Created ${dateFormat.format(purpose.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => context.push(
                  '${AppPaths.purposeEdit}?skillId=$skillId&purposeId=${purpose.id}',
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => _confirmDelete(context, ref, purpose),
                icon: Icon(
                  Icons.delete,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
                label: Text(
                  'Delete',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Purpose purpose) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purpose?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this purpose statement?'),
            const SizedBox(height: 12),
            Text(
              '"${purpose.statement}"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This won\'t delete the skill itself.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(purposesProvider.notifier).deletePurpose(
                purpose.id!,
                purpose.skillId,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purpose deleted')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(PurposeCategory category) {
    switch (category) {
      case PurposeCategory.personalExpression:
        return 'Personal Expression';
      case PurposeCategory.connectingWithOthers:
        return 'Connecting with Others';
      case PurposeCategory.careerGrowth:
        return 'Career Growth';
      case PurposeCategory.selfImprovement:
        return 'Self Improvement';
      case PurposeCategory.contributingBeyondSelf:
        return 'Contributing Beyond Self';
      case PurposeCategory.other:
        return 'Other';
    }
  }
}
