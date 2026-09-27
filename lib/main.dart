import 'package:flutter/widgets.dart';
import 'app.dart';
import 'core/state/app_state.dart';

/// Restore local demo progress before mounting the localized Flutter app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.restore();
  runApp(FutureExpressApp(state: state));
}
