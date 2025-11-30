import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deliberate_practice_app/core/theme/app_colors.dart';
import 'package:deliberate_practice_app/shared/widgets/loading_indicator.dart';

/// An error view widget.
class ErrorView extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData icon;
  
  const ErrorView({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.icon = Icons.error_outline,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A network error view.
class NetworkErrorView extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const NetworkErrorView({
    super.key,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return ErrorView(
      icon: Icons.wifi_off,
      message: 'No internet connection',
      details: 'Please check your network settings and try again.',
      onRetry: onRetry,
    );
  }
}

/// A generic failure error view.
class FailureView extends StatelessWidget {
  final String? failureMessage;
  final VoidCallback? onRetry;
  
  const FailureView({
    super.key,
    this.failureMessage,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return ErrorView(
      message: 'Something went wrong',
      details: failureMessage ?? 'An unexpected error occurred. Please try again.',
      onRetry: onRetry,
    );
  }
}

/// An inline error widget for smaller error displays.
class InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const InlineError({
    super.key,
    required this.message,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              color: AppColors.error,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper widget to handle async value states.
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });
  
  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: loading ?? () => const LoadingIndicator(),
      error: error ?? (e, st) => FailureView(failureMessage: e.toString()),
    );
  }
}
