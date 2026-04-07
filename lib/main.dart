import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/error/global_error_handler.dart';
import 'providers/service_registry.dart';
import 'services/startup/app_startup_coordinator.dart';

void main() async {
  GlobalErrorHandler.install();
  await AppStartupCoordinator.initialize();

  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(
    UncontrolledProviderScope(
      container: appProviderContainer,
      child: const LegadoApp(),
    ),
  );
}
