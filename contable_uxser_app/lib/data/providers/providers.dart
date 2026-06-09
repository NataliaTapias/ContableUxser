import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/supabase/supabase_config.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/producto_repository_impl.dart';
import '../../data/repositories/venta_repository_impl.dart';
import '../../data/repositories/caja_repository_impl.dart';
import '../../data/sync/sync_service.dart';
import '../../domain/repositories/producto_repository.dart';
import '../../domain/repositories/venta_repository.dart';
import '../../domain/repositories/caja_repository.dart';
import '../../domain/repositories/auth_repository.dart';

final dioClientProvider = Provider<DioClient>((_) => DioClient());

final networkInfoProvider = Provider<NetworkInfo>((_) => NetworkInfo(Connectivity()));

final supabaseClientProvider = Provider<SupabaseClient?>((_) {
  if (SupabaseConfig.isConfigured) {
    return Supabase.instance.client;
  }
  return null;
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(ref.watch(dioClientProvider));
});

final productoRepositoryProvider = Provider<ProductoRepository>((ref) {
  return ProductoRepositoryImpl(ref.watch(dioClientProvider));
});

final ventaRepositoryProvider = Provider<VentaRepository>((ref) {
  return VentaRepositoryImpl(ref.watch(dioClientProvider));
});

final cajaRepositoryProvider = Provider<CajaRepository>((ref) {
  return CajaRepositoryImpl(ref.watch(dioClientProvider));
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(networkInfoProvider),
    ref.watch(ventaRepositoryProvider),
  );
});
