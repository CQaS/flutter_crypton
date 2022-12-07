import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crypton/config/app_setting.dart';
import 'package:flutter_crypton/config/hive_config.dart';
import 'package:flutter_crypton/mi_aplicativo.dart';
import 'package:flutter_crypton/pages/home_page.dart';
import 'package:flutter_crypton/repos/conta_repo.dart';
import 'package:flutter_crypton/repos/favoritos_repo.dart';
import 'package:flutter_crypton/repos/moneda_repo.dart';
import 'package:flutter_crypton/services/auth_services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthServices()),
        ChangeNotifierProvider(create: (context) => MonedaRepo()),
        ChangeNotifierProvider(
            create: (context) => ContaRepo(
                  monedas: context.read<MonedaRepo>(),
                )),
        ChangeNotifierProvider(create: (context) => AppSetting()),
        ChangeNotifierProvider(
            create: (context) => FavoritosRepo(
                  auth: context.read<AuthServices>(),
                  monedas: context.read<MonedaRepo>(),
                )),
      ],
      child: const MiAplicativo(),
    ),
  );
}
