import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get instance async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos (
        id TEXT PRIMARY KEY,
        empresa_id TEXT NOT NULL,
        codigo_barras TEXT NOT NULL,
        nombre TEXT NOT NULL,
        costo_promedio REAL NOT NULL DEFAULT 0,
        precio_venta REAL NOT NULL DEFAULT 0,
        stock_actual REAL NOT NULL DEFAULT 0,
        stock_minimo REAL NOT NULL DEFAULT 0,
        ubicacion TEXT,
        fecha_registro TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE ventas (
        id TEXT PRIMARY KEY,
        empresa_id TEXT NOT NULL,
        sesion_caja_id TEXT NOT NULL,
        usuario_id TEXT NOT NULL,
        fecha_venta TEXT NOT NULL,
        total REAL NOT NULL,
        metodo_pago TEXT NOT NULL,
        referencia_transferencia TEXT,
        sincronizado_nube INTEGER NOT NULL DEFAULT 0,
        fecha_registro TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE venta_detalles (
        id TEXT PRIMARY KEY,
        venta_id TEXT NOT NULL,
        producto_id TEXT NOT NULL,
        cantidad REAL NOT NULL,
        precio_unitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entidad TEXT NOT NULL,
        entidad_id TEXT NOT NULL,
        accion TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'pendiente',
        intentos INTEGER NOT NULL DEFAULT 0,
        error TEXT,
        fecha_creacion TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('CREATE INDEX idx_ventas_sync ON ventas(sincronizado_nube)');
    await db.execute('CREATE INDEX idx_productos_codigo ON productos(codigo_barras)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrations for future versions
  }
}
