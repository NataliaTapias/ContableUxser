import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/supabase/supabase_client.dart';
import 'core/supabase/supabase_config.dart';
import 'di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  if (SupabaseConfig.isConfigured) {
    await SupabaseClientWrapper.initialize();
  }

  await InjectionContainer.init();
  runApp(const ProviderScope(child: ContableUxserApp()));
}
