import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabasePublishableKey => dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabasePublishableKey.isNotEmpty &&
      supabaseUrl != 'https://your-project-id.supabase.co' &&
      supabasePublishableKey != 'your-publishable-key-here';
}
