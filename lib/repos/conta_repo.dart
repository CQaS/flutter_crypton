import 'package:flutter/widgets.dart';
import 'package:flutter_crypton/database/db.dart';
import 'package:flutter_crypton/models/moneda.dart';
import 'package:flutter_crypton/models/posicion.dart';
import 'package:flutter_crypton/repos/moneda_repo.dart';
import 'package:sqflite/sqflite.dart';

import '../models/historico.dart';

class ContaRepo extends ChangeNotifier {
  late Database db;
  List<Posicion> _cartera = [];
  List<Historico> _historico = [];
  double _saldo = 0;
  MonedaRepo monedas;

  get saldo => _saldo;
  List<Posicion> get cartera => _cartera;
  List<Historico> get historico => _historico;

  ContaRepo({required this.monedas}) {
    _initRepo();
  }

  _initRepo() async {
    await _getSaldo();
    await _getCartera();
    await _getHistorico();
  }

  _getSaldo() async {
    db = await DB.instance.database;
    List conta = await db.query('conta', limit: 1);
    _saldo = conta.first['saldo'];
    notifyListeners();
  }

  setSaldo(double valor) async {
    db = await DB.instance.database;
    db.update(
      'conta',
      {'saldo': valor},
    );
    _saldo = valor;
    notifyListeners();
  }

  comprar(Moneda moneda, double valor) async {
    db = await DB.instance.database;
    await db.transaction((txn) async {
      final posicionMoneda = await txn
          .query('cartera', where: 'sigla = ?', whereArgs: [moneda.sigla]);
      //sino tengo la moneda en cartera...
      if (posicionMoneda.isEmpty) {
        await txn.insert('cartera', {
          'sigla': moneda.sigla,
          'moneda': moneda.nombre,
          'cantidades': (valor / moneda.precio).toString()
        });
      } else {
        //sino esta la moneda en la cartera...
        final actual =
            double.parse(posicionMoneda.first['cantidades'].toString());
        await txn.update(
          'cartera',
          {
            'cantidades': (actual + (valor / moneda.precio)).toString(),
          },
          where: 'sigla = ?',
          whereArgs: [moneda.sigla],
        );
      }

      //insert compra historica
      await txn.insert('historico', {
        'sigla': moneda.sigla,
        'moneda': moneda.nombre,
        'cantidades': (valor / moneda.precio).toString(),
        'valor': valor,
        'tipo_operacion': 'compra',
        'data_operacion': DateTime.now().microsecondsSinceEpoch,
      });

      //actualizar saldo
      await txn.update('saldo', {'saldo': saldo - valor});

      await _initRepo();
      notifyListeners();
    });
  }

  _getCartera() async {
    _cartera = [];
    List posiciones = await db.query('cartera');
    posiciones.forEach((pos) {
      Moneda moneda = monedas.tabla.firstWhere(
        (m) => m.sigla == pos['sigla'],
      );
      _cartera.add(Posicion(
        moneda: moneda,
        cantidad: double.parse(pos['cantidades']),
      ));
    });

    notifyListeners();
  }

  _getHistorico() async {
    _historico = [];
    List operaciones = await db.query('historico');
    operaciones.forEach((ope) {
      Moneda moneda = monedas.tabla.firstWhere(
        (m) => m.sigla == ope['sigla'],
      );
      _historico.add(
        Historico(
          dataOperacion:
              DateTime.fromMillisecondsSinceEpoch(ope['dataOperacion']),
          tipoOperacion: ope['tipo_operacion'],
          moneda: moneda,
          valor: ope['valor'],
          cantidad: double.parse(ope['cantidad']),
        ),
      );
    });

    notifyListeners();
  }
}
