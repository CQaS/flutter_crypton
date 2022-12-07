import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_crypton/database/db.dart';
import 'package:flutter_crypton/models/moneda.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

/* class MonedaRepo {
  static List<Moneda> tabla = [
    Moneda(
      icon: 'images/bit.png',
      nombre: 'Bitcoin',
      sigla: 'BTC',
      precio: 234.7,
    ),
    Moneda(
      icon: 'images/car.png',
      nombre: 'Cardcoin',
      sigla: 'CCN',
      precio: 24.7,
    ),
    Moneda(
      icon: 'images/ete.png',
      nombre: 'Etherium',
      sigla: 'ETM',
      precio: 304.7,
    ),
    Moneda(
      icon: 'images/lite.png',
      nombre: 'LiteCoin',
      sigla: 'LTC',
      precio: 500.7,
    ),
    Moneda(
      icon: 'images/usd.png',
      nombre: 'USDCoin',
      sigla: 'USD',
      precio: 2.7,
    ),
  ];
}
 */

class MonedaRepo extends ChangeNotifier {
  List<Moneda> _tabla = [];
  late Timer intervalo;

  List<Moneda> get tabla => _tabla;

  MonedaRepo() {
    _setupMonedaTabla();
    _setupDatosTablaMoneda();
    _readMonedaTabla();
    _refreshPrecios();
  }

  _refreshPrecios() async {
    intervalo = Timer.periodic(Duration(minutes: 5), (_) => checkPrecios());
  }

  getHistoricoMoneda(Moneda moneda) async {
    final res = await http.get(
      Uri.parse(
        'https://api.coinbase.com/v2/assets/prices/${moneda.baseId}?base=BRL',
      ),
    );
    List<Map<String, dynamic>> precios = [];

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final Map<String, dynamic> moneda = json['data']['prices'];

      precios.add(moneda['hour']);
      precios.add(moneda['day']);
      precios.add(moneda['week']);
      precios.add(moneda['month']);
      precios.add(moneda['year']);
      precios.add(moneda['all']);
    }
  }

  checkPrecios() async {
    String url = 'https://api.coinbase.com/v2/assets/search?base=BRL';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> monedas = json['data'];
      Database db = DB.instance.database;
      Batch batch = db.batch();

      _tabla.forEach((actual) {
        monedas.forEach((nuevas) {
          if (actual.baseId == nuevas['base_id']) {
            final moneda = nuevas['pirces'];
            final precio = nuevas['lates_price'];
            final timestamp = DateTime.parse(precio['timestamp']);

            batch.update(
              'monedas',
              {
                'precio': moneda['latest'],
                'timestamp': timestamp.millisecondsSinceEpoch,
                'cambioHora': precio['percent_change']['hour'].toString(),
                'cambioDia': precio['percent_change']['day'].toString(),
                'cambioSemana': precio['percent_change']['week'].toString(),
                'cambioMes': precio['percent_change']['month'].toString(),
                'cambioAnio': precio['percent_change']['year'].toString(),
                'cambioPeriodoTotal': precio['percent_change']['all'].toString()
              },
              where: 'baseId=?',
              whereArgs: [actual.baseId],
            );
          }
        });
      });

      await batch.commit(noResult: true);
      await _readMonedaTabla();
    }
  }

  _readMonedaTabla() async {
    Database db = DB.instance.database;
    List resul = await db.query('monedas');

    _tabla = resul.map((row) {
      return Moneda(
        baseId: row['baseId'],
        icon: row['icon'],
        nombre: row['nombre'],
        sigla: row['sigla'],
        precio: row['precio'],
        timestamp: DateTime.fromMicrosecondsSinceEpoch(row['timestamp']),
        cambioHora: double.parse(row['cambioHora']),
        cambioDia: double.parse(row['cambioDia']),
        cambioSemana: double.parse(row['cambioSemana']),
        cambioMes: double.parse(row['cambioMes']),
        cambioAnio: double.parse(row['cambioAnio']),
        cambioPeriodoTotal: double.parse(row['cambioPeriodoTotal']),
      );
    }).toList();

    notifyListeners();
  }

  _monedaTablaIsEmpty() async {
    Database db = await DB.instance.database;
    List res = await db.query('monedas');
    return res.isEmpty;
  }

  _setupDatosTablaMoneda() async {
    //if (await _monedaTablaIsEmpty()) {
    if (true) {
      String url = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> monedas = json['data'];
        Database db = DB.instance.database;
        Batch batch = db.batch();

        monedas.forEach((moneda) {
          final precio = moneda['latest_price'];
          final timestamp = DateTime.parse(precio['timestamp']);

          batch.insert('monedas', {
            'baseId': moneda['id'],
            'icon': moneda['image_url'],
            'nombre': moneda['name'],
            'sigla': moneda['symbol'],
            'precio': moneda['latest'],
            'timestamp': timestamp.millisecondsSinceEpoch,
            'cambioHora': precio['percent_change']['hour'].toString(),
            'cambioDia': precio['percent_change']['day'].toString(),
            'cambioSemana': precio['percent_change']['week'].toString(),
            'cambioMes': precio['percent_change']['month'].toString(),
            'cambioAnio': precio['percent_change']['year'].toString(),
            'cambioPeriodoTotal': precio['percent_change']['all'].toString()
          });
        });
        batch.commit(noResult: true);
      }
    }
  }

  _setupMonedaTabla() async {
    final String table = '''
          CREATE TABLE IF NOT EXISTS monedas(
            baseId TEXT PRIMARY KEY,
            icon TEXT,
            nombre TEXT,
            sigla TEXT,
            precio TEXT,
            timestamp INTEGER,
            cambioHora TEXT,
            cambioDia TEXT,
            cambioSemana TEXT,
            cambioMes TEXT,
            cambioAnio TEXT,
            cambioPeriodoTotal TEXT
          );
      ''';

    Database db = await DB.instance.database;
    await db.execute(table);
  }
}
