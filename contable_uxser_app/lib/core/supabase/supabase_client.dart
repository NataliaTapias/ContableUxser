import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseClientWrapper {
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception(
        'Supabase no está configurado. '
        'Configura SUPABASE_URL y SUPABASE_ANON_KEY en el archivo .env',
      );
    }

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      publishableKey: SupabaseConfig.supabasePublishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
