import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSetting extends ChangeNotifier {
  /* CON SHAREDPREFERENCE

  late SharedPreferences _pref;

  Map<String, String> localizacion = {
    'localizacion': 'pt_BR',
    'nombre': 'R\$',
  };

  AppSetting() {
    _startSetting();
  }

  _startSetting() async {
    await _startPreferences();
    await _readLocal();
  }

  Future<void> _startPreferences() async {
    _pref = await SharedPreferences.getInstance();
  }

  _readLocal() {
    final localiza = _pref.getString('local') ?? 'pt_BR';
    final nombre = _pref.getString('local') ?? 'R\$';
    localizacion = {
      'localizacion': localiza,
      'nombre': nombre,
    };

    notifyListeners();
  }

  setLocal(String localizacion, String nombre) async {
    await _pref.setString('localizacion', localizacion);
    await _pref.setString('nombre', nombre);
    await _readLocal();
  } */

  /* CON HIVE */

  late Box box;

  Map<String, String> localizacion = {
    'localizacion': 'pt_BR',
    'nombre': 'R\$',
  };

  AppSetting() {
    _startSetting();
  }

  _startSetting() async {
    await _startPreferences();
    await _readLocal();
  }

  Future<void> _startPreferences() async {
    box = await Hive.openBox('preference');
  }

  _readLocal() {
    final localiza = box.get('local') ?? 'pt_BR';
    final nombre = box.get('local') ?? 'R\$';
    localizacion = {
      'localizacion': localiza,
      'nombre': nombre,
    };

    notifyListeners();
  }

  setLocal(String localizacion, String nombre) async {
    await box.put('localizacion', localizacion);
    await box.put('nombre', nombre);
    await _readLocal();
  }
}
