import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crypton/adapter/moneda_hive_adapter.dart';
import 'package:flutter_crypton/database/db_firestore.dart';
import 'package:flutter_crypton/models/moneda.dart';
import 'package:flutter_crypton/repos/moneda_repo.dart';
import 'package:flutter_crypton/services/auth_services.dart';
//import 'package:hive/hive.dart';

class FavoritosRepo extends ChangeNotifier {
  final List<Moneda> _lista = [];
  //late LazyBox box;
  late FirebaseFirestore db;
  late AuthServices auth;
  MonedaRepo monedas;

  FavoritosRepo({required this.auth, required this.monedas}) {
    _startRepo();
  }

  _startRepo() async {
    //await _openBox();
    await _startFirestore();
    await _readFavoritos();
  }

  /* _openBox() async {
    Hive.registerAdapter(MonedaHiveAdapter());
    box = await Hive.openLazyBox('monedas_favoritas');
  } */

  _startFirestore() {
    db = DBFirestore.get();
  }

  _readFavoritos() async {
    /* box.keys.forEach((monedas) async {
      Moneda m = await box.get(monedas);
      _lista.add(m);
      notifyListeners();
    }); */
    if (auth.usuario != null && _lista.isEmpty) {
      final snapshot =
          await db.collection('usuarios/${auth.usuario!.uid}/favoritas').get();

      snapshot.docs.forEach((doc) {
        Moneda moneda = monedas.tabla
            .firstWhere((moneda) => moneda.sigla == doc.get('sigla'));
        _lista.add(moneda);
        notifyListeners();
      });
    }
  }

  UnmodifiableListView<Moneda> get lista => UnmodifiableListView(_lista);

  saveAll(List<Moneda> monedas) {
    monedas.forEach((moneda) async {
      if (!_lista.any((actual) => actual.sigla == moneda.sigla)) {
        _lista.add(moneda);
        //box.put(moneda.sigla, moneda);
        await db
            .collection('usuario/${auth.usuario!.uid}/favoritas')
            .doc(moneda.sigla)
            .set({
          'moneda': moneda.nombre,
          'sigla': moneda.sigla,
          'precio': moneda.precio
        });
      }
    });
    notifyListeners();
  }

  remove(Moneda moneda) async {
    await db
        .collection('usuario/${auth.usuario!.uid}/favoritas')
        .doc(moneda.sigla)
        .delete();
    _lista.remove(moneda);
    notifyListeners();
  }
}
