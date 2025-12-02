import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_loop/app.dart';
import 'package:prompt_loop/services/share_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize share service to receive shared content from other apps
  ShareService.initialize();

  runApp(const ProviderScope(child: PromptLoopApp()));
}
