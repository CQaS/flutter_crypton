import 'package:flutter/material.dart';
import 'package:flutter_crypton/pages/home_page.dart';
import 'package:flutter_crypton/widget/auth_check.dart';

class MiAplicativo extends StatelessWidget {
  const MiAplicativo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Monedas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const AuthCheck(),
    );
  }
}
