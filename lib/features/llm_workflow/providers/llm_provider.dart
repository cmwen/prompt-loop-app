import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_loop/data/services/copy_paste_llm_service.dart';
import 'package:prompt_loop/data/services/ollama_llm_service.dart';
import 'package:prompt_loop/domain/entities/app_settings.dart';
import 'package:prompt_loop/domain/services/llm_service.dart';
import 'package:prompt_loop/features/settings/providers/settings_provider.dart';

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

/// Provider to check if BYOK is configured (deprecated).
final isByokConfiguredProvider = FutureProvider<bool>((ref) async {
  return false; // BYOK is no longer supported
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

/// Provider for creating an Ollama service instance.
final ollamaServiceProvider = FutureProvider<OllamaLlmService?>((ref) async {
  final settings = ref.watch(settingsProvider);

  return settings.when(
    data: (s) async {
      if (s.llmMode != LlmMode.ollama) return null;

      final model = s.ollamaDefaultModel;
      if (model == null || model.isEmpty) return null;

      return OllamaLlmService(baseUrl: s.ollamaBaseUrl, model: model);
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

/// Provider to check if Ollama is configured.
final isOllamaConfiguredProvider = FutureProvider<bool>((ref) async {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (s) =>
        s.llmMode == LlmMode.ollama &&
        s.ollamaDefaultModel != null &&
        s.ollamaDefaultModel!.isNotEmpty,
    loading: () => false,
    error: (_, _) => false,
  );
});
