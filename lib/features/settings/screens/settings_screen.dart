import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:prompt_loop/core/router/app_router.dart';
import 'package:prompt_loop/domain/entities/app_settings.dart';
import 'package:prompt_loop/features/settings/providers/settings_provider.dart';
import 'package:prompt_loop/features/skills/providers/skills_provider.dart';
import 'package:prompt_loop/features/tasks/providers/tasks_provider.dart';
import 'package:prompt_loop/features/practice/providers/practice_provider.dart';
import 'package:prompt_loop/features/purpose/providers/purpose_provider.dart';
import 'package:prompt_loop/shared/widgets/app_card.dart';
import 'package:prompt_loop/shared/widgets/loading_indicator.dart';
import 'package:prompt_loop/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Settings screen for app configuration.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Settings')),
          settings.when(
            data: (settingsData) => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // LLM Mode section
                  _SectionHeader(title: 'AI Assistant'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LLM Mode',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose how you want to use AI for skill analysis and task generation.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...LlmMode.values.map(
                          (mode) => RadioListTile<LlmMode>(
                            title: Text(
                              mode == LlmMode.copyPaste
                                  ? 'Copy-Paste'
                                  : 'Bring Your Own Key',
                            ),
                            subtitle: Text(
                              mode == LlmMode.copyPaste
                                  ? 'Copy prompts to ChatGPT, Claude, etc.'
                                  : 'Use your own API key for direct integration',
                            ),
                            value: mode,
                            groupValue: settingsData.llmMode,
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .setLlmMode(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // API Key section (only if BYOK mode)
                  if (settingsData.llmMode == LlmMode.byok) ...[
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'API Key',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _showApiKeyDialog(context, ref),
                                child: const Text('Configure'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<String?>(
                            future: ref
                                .read(settingsProvider.notifier)
                                .getApiKey(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.success,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'API key configured',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.success),
                                    ),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    color: AppColors.warning,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'No API key configured',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppColors.warning),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LLM Provider',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<LlmProvider>(
                            value: settingsData.llmProvider,
                            isExpanded: true,
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .setLlmProvider(value);
                              }
                            },
                            items: LlmProvider.values
                                .map(
                                  (provider) => DropdownMenuItem(
                                    value: provider,
                                    child: Text(provider.name.toUpperCase()),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Appearance section
                  _SectionHeader(title: 'Appearance'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose your preferred color scheme',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...AppThemeMode.values.map(
                          (mode) => RadioListTile<AppThemeMode>(
                            title: Text(mode.displayName),
                            subtitle: Text(mode.description),
                            value: mode,
                            groupValue: settingsData.themeMode,
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .setThemeMode(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content Management section
                  _SectionHeader(title: 'Content'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.flag_outlined),
                          title: const Text('My Purposes'),
                          subtitle: const Text(
                            'Manage learning goals for your skills',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(AppPaths.purposesList),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data Management section
                  _SectionHeader(title: 'Data'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Export Data'),
                      subtitle: const Text(
                        'Export all your data as JSON',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _exportData(context, ref),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notifications section
                  _SectionHeader(title: 'Notifications'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Practice Reminders'),
                          subtitle: const Text(
                            'Get daily reminders to practice',
                          ),
                          value: settingsData.notificationsEnabled,
                          onChanged: (value) {
                            ref
                                .read(settingsProvider.notifier)
                                .setNotificationsEnabled(value);
                          },
                        ),
                        if (settingsData.notificationsEnabled) ...[
                          const Divider(),
                          ListTile(
                            title: const Text('Reminder Time'),
                            subtitle: Text(settingsData.dailyReminderTime),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                _showTimePicker(context, ref, settingsData),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About section
                  _SectionHeader(title: 'About'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: [
                        FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, snapshot) {
                            final version = snapshot.data?.version ?? '1.0.0';
                            final buildNumber = snapshot.data?.buildNumber ?? '1';
                            return ListTile(
                              leading: const Icon(Icons.info_outline),
                              title: const Text('Version'),
                              trailing: Text('$version+$buildNumber'),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () => _launchUrl(
                            context,
                            'https://cmwen.github.io/prompt-loop-app/privacy',
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: const Text('Help & Support'),
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () => _launchUrl(
                            context,
                            'https://github.com/cmwen/prompt-loop-app/issues',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reset section
                  _SectionHeader(title: 'Reset'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: ListTile(
                      leading: const Icon(Icons.restore_outlined),
                      title: const Text('Show Onboarding'),
                      subtitle: const Text(
                        'Reset and show onboarding screens again',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Reset Onboarding?'),
                            content: const Text(
                              'This will show the onboarding screens again on next app restart.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .resetOnboarding();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Onboarding reset'),
                                    ),
                                  );
                                },
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ]),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: LoadingIndicator(message: 'Loading settings...'),
            ),
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configure API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your OpenAI API key. It will be stored securely.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'sk-...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).clearApiKey();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref
                    .read(settingsProvider.notifier)
                    .saveApiKey(controller.text);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final formattedTime =
          '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
      ref.read(settingsProvider.notifier).setDailyReminderTime(formattedTime);
    }
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Exporting data...'),
              ],
            ),
          ),
        );
      }

      // Gather all data
      final skillsValue = ref.read(skillsProvider);
      final tasksValue = ref.read(tasksProvider);
      final sessionsValue = ref.read(practiceSessionsProvider);
      final purposesValue = ref.read(purposesProvider);

      final skills = skillsValue.valueOrNull ?? [];
      final tasks = tasksValue.valueOrNull ?? [];
      final sessions = sessionsValue.valueOrNull ?? [];
      final purposes = purposesValue.valueOrNull ?? [];

      final exportData = {
        'export_version': '1.0',
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.3',
        'data': {
          'skills': skills.map((s) => {
            'id': s.id,
            'name': s.name,
            'description': s.description,
            'current_level': s.currentLevel.name,
            'target_level': s.targetLevel?.name,
            'created_at': s.createdAt.toIso8601String(),
          }).toList(),
          'tasks': tasks.map((t) => {
            'id': t.id,
            'skill_id': t.skillId,
            'title': t.title,
            'description': t.description,
            'duration_minutes': t.durationMinutes,
            'difficulty': t.difficulty,
            'is_completed': t.isCompleted,
            'completed_at': t.completedAt?.toIso8601String(),
            'created_at': t.createdAt.toIso8601String(),
          }).toList(),
          'practice_sessions': sessions.map((s) => {
            'id': s.id,
            'task_id': s.taskId,
            'started_at': s.startedAt.toIso8601String(),
            'completed_at': s.completedAt?.toIso8601String(),
            'duration_seconds': s.actualDurationSeconds,
            'rating': s.rating,
            'notes': s.notes,
          }).toList(),
          'purposes': purposes.map((p) => {
            'id': p.id,
            'skill_id': p.skillId,
            'statement': p.statement,
            'category': p.category.name,
            'created_at': p.createdAt.toIso8601String(),
          }).toList(),
        },
      };

      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Save to temporary file
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'prompt_loop_export_$timestamp.json';
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Prompt Loop Data Export',
        text: 'Your Prompt Loop data export from ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $urlString')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
