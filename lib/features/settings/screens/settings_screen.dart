import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_loop/domain/entities/app_settings.dart';
import 'package:prompt_loop/features/settings/providers/settings_provider.dart';
import 'package:prompt_loop/shared/widgets/app_card.dart';
import 'package:prompt_loop/shared/widgets/loading_indicator.dart';
import 'package:prompt_loop/core/theme/app_colors.dart';

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
                    child: SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Use dark color scheme'),
                      value: settingsData.isDarkMode,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).setDarkMode(value);
                      },
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
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Version'),
                          trailing: const Text('1.0.0'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Show privacy policy
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: const Text('Help & Support'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Show help
                          },
                        ),
                      ],
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
