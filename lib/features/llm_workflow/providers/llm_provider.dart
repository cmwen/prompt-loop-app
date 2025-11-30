import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deliberate_practice_app/data/services/copy_paste_llm_service.dart';
import 'package:deliberate_practice_app/data/services/byok_llm_service.dart';
import 'package:deliberate_practice_app/domain/entities/app_settings.dart';
import 'package:deliberate_practice_app/domain/services/llm_service.dart';
import 'package:deliberate_practice_app/features/settings/providers/settings_provider.dart';

/// Provider for the current LLM service based on settings.
final llmServiceProvider = Provider<LlmService?>((ref) {
  // This will be overridden when the workflow state is available
  // For now, return null as the service needs UI callbacks
  return null;
});

/// Provider for the copy-paste workflow state.
final copyPasteWorkflowProvider =
    StateNotifierProvider<CopyPasteWorkflowNotifier, CopyPasteWorkflowState>((
      ref,
    ) {
      return CopyPasteWorkflowNotifier();
    });

/// Provider to check if BYOK is configured.
final isByokConfiguredProvider = FutureProvider<bool>((ref) async {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (s) async {
      if (s.llmMode != LlmMode.byok) return false;
      final notifier = ref.read(settingsProvider.notifier);
      final apiKey = await notifier.getApiKey();
      return apiKey != null && apiKey.isNotEmpty;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Notifier for the copy-paste workflow state.
class CopyPasteWorkflowNotifier extends StateNotifier<CopyPasteWorkflowState> {
  CopyPasteWorkflowNotifier() : super(const CopyPasteWorkflowState.initial());

  void setPromptReady(String prompt) {
    state = state.copyWith(
      currentStep: CopyPasteStep.promptReady,
      currentPrompt: prompt,
      errorMessage: null,
    );
  }

  void setAwaitingResponse() {
    state = state.copyWith(currentStep: CopyPasteStep.awaitingResponse);
  }

  void setProcessing() {
    state = state.copyWith(currentStep: CopyPasteStep.processing);
  }

  void setCompleted(String response) {
    state = state.copyWith(
      currentStep: CopyPasteStep.completed,
      pastedResponse: response,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      currentStep: CopyPasteStep.error,
      errorMessage: message,
    );
  }

  void reset() {
    state = const CopyPasteWorkflowState.initial();
  }

  /// Create a CopyPasteLlmService with callbacks that update this state.
  CopyPasteLlmService createService({
    required Future<void> Function(String prompt) onShowPrompt,
    required Future<String?> Function() onGetResponse,
  }) {
    return CopyPasteLlmService(
      onPromptReady: (prompt) async {
        setPromptReady(prompt);
        await onShowPrompt(prompt);
        setAwaitingResponse();
      },
      onResponseReceived: () async {
        final response = await onGetResponse();
        if (response != null && response.isNotEmpty) {
          setProcessing();
          setCompleted(response);
        }
        return response;
      },
    );
  }
}

/// Provider for creating a BYOK service instance.
final byokServiceProvider = FutureProvider<ByokLlmService?>((ref) async {
  final settings = ref.watch(settingsProvider);

  return settings.when(
    data: (s) async {
      if (s.llmMode != LlmMode.byok) return null;

      final notifier = ref.read(settingsProvider.notifier);
      final apiKey = await notifier.getApiKey();

      if (apiKey == null || apiKey.isEmpty) return null;

      return ByokLlmService(
        apiKey: apiKey,
        provider: s.llmProvider,
        model: s.llmModel,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
