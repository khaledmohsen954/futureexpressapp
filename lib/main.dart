import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/services_locator_imports.dart';
import 'core/state/app_state.dart';

/// Restore local preferences before mounting the localized Flutter app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('app');
  await initDependencies();
  final state = AppState();
  await state.restore();
  runApp(FutureExpressApp(state: state));
}
