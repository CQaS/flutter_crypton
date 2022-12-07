import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DB {
  //constructir privado
  DB._();
  //instancia de DB
  static final DB instance = DB._();
//instancia de SQLite
  static Database? _database;

  get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'cripto.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(db, ver) async {
    await db.execute(_conta);
    await db.execute(_cartera);
    await db.execute(_historico);
    await db.insert('conta', {'saldo': 0});
  }

  String get _conta => '''
    CREATE TABLE conta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      saldo REAL
    );
  ''';

  String get _cartera => '''
    CREATE TABLE cartera(
      sigla TEXT PRIMARY KEY,
      moneda TEXT,
      cantidades TEXT
    );
  ''';

  String get _historico => '''
    CREATE TABLE historico(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      data_operacion INT,
      tipo_operacion TEXT,
      moneda TEXT,
      sigla TEXT,
      valor TEXT,
      cantidad TEXT
    );
  ''';
}
