import 'dart:async';
import '../../core/network/network_info.dart';
import '../../domain/repositories/venta_repository.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncService {
  final NetworkInfo _networkInfo;
  final VentaRepository _ventaRepository;

  SyncService(
    this._networkInfo,
    this._ventaRepository,
  );

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  Timer? _timer;
  bool _isSyncing = false;

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  void startAutoSync() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => syncIfNeeded());
  }

  void stopAutoSync() {
    _timer?.cancel();
  }

  Future<void> syncIfNeeded() async {
    if (_isSyncing) return;

    final online = await _networkInfo.isConnected;
    if (!online) return;

    _isSyncing = true;
    _currentStatus = SyncStatus.syncing;
    _statusController.add(SyncStatus.syncing);

    try {
      await _ventaRepository.syncVentasPendientes();

      _currentStatus = SyncStatus.success;
      _statusController.add(SyncStatus.success);

      Future.delayed(const Duration(seconds: 3), () {
        _currentStatus = SyncStatus.idle;
        _statusController.add(SyncStatus.idle);
      });
    } catch (e) {
      _currentStatus = SyncStatus.error;
      _statusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> forceSync() async {
    if (_isSyncing) return false;
    await syncIfNeeded();
    return true;
  }

  void dispose() {
    _timer?.cancel();
    _statusController.close();
  }
}
