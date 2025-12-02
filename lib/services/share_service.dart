import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Service for handling sharing prompts and receiving shared text.
class ShareService {
  static StreamSubscription? _intentDataStreamSubscription;

  /// Stream controller for incoming shared text
  static final _sharedTextController = StreamController<String>.broadcast();

  /// Stream of text shared to the app from other apps
  static Stream<String> get sharedTextStream => _sharedTextController.stream;

  /// Initialize the share service and listen for incoming shares
  static void initialize() {
    debugPrint('[ShareService] Initializing...');

    // Note: For text sharing from other apps, we'll rely on manual clipboard paste
    // The receive_sharing_intent package primarily handles file/media sharing
    // Text intent handling requires platform-specific implementation

    // Users will:
    // 1. Copy the prompt from our app
    // 2. Paste it into ChatGPT/Claude
    // 3. Copy the response
    // 4. Paste it back into our response field

    debugPrint(
      '[ShareService] Initialized - Users can use clipboard for text sharing',
    );
  }

  /// Share text to other apps (e.g., prompt to LLM apps)
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject ?? 'Prompt from Prompt Loop');
  }

  /// Share text with a dialog that shows available apps
  static Future<ShareResult> shareTextWithResult(
    String text, {
    String? subject,
  }) async {
    return await Share.share(
      text,
      subject: subject ?? 'Prompt from Prompt Loop',
    );
  }

  /// Dispose the service
  static void dispose() {
    _intentDataStreamSubscription?.cancel();
    _sharedTextController.close();
  }
}
