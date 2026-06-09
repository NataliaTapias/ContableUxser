import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../core/supabase/supabase_config.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/caja_repository_impl.dart';
import '../data/repositories/producto_repository_impl.dart';
import '../data/repositories/venta_repository_impl.dart';
import '../data/sync/sync_service.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/caja_repository.dart';
import '../domain/repositories/producto_repository.dart';
import '../domain/repositories/venta_repository.dart';

class InjectionContainer {
  static late final SharedPreferences prefs;
  static late final DioClient dioClient;
  static late final NetworkInfo networkInfo;

  static late final AuthRepository authRepository;
  static late final ProductoRepository productoRepository;
  static late final VentaRepository ventaRepository;
  static late final CajaRepository cajaRepository;

  static late final SyncService syncService;

  static SupabaseClient? get supabaseClient =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    dioClient = DioClient();
    networkInfo = NetworkInfo(Connectivity());

    authRepository = AuthRepositoryImpl(dioClient);
    productoRepository = ProductoRepositoryImpl(dioClient);
    ventaRepository = VentaRepositoryImpl(dioClient);
    cajaRepository = CajaRepositoryImpl(dioClient);

    syncService = SyncService(networkInfo, ventaRepository);
  }
}
