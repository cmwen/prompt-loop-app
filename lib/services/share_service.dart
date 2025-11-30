import 'dart:async';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Service for handling sharing prompts and receiving shared text.
class ShareService {
  static const _channel = MethodChannel('prompt_loop/share');
  
  /// Stream controller for incoming shared text
  static final _sharedTextController = StreamController<String>.broadcast();
  
  /// Stream of text shared to the app from other apps
  static Stream<String> get sharedTextStream => _sharedTextController.stream;
  
  /// Initialize the share service and listen for incoming shares
  static void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  /// Handle method calls from native code
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onSharedText':
        final text = call.arguments as String?;
        if (text != null && text.isNotEmpty) {
          _sharedTextController.add(text);
        }
        break;
    }
  }
  
  /// Share text to other apps (e.g., prompt to LLM apps)
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(
      text,
      subject: subject ?? 'Prompt from Prompt Loop',
    );
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
    _sharedTextController.close();
  }
}
