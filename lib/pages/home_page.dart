import 'package:flutter/material.dart';
import 'package:flutter_crypton/pages/cartera_page.dart';
import 'package:flutter_crypton/pages/configuraciones_page.dart';
import 'package:flutter_crypton/pages/favoritas_page.dart';
import 'package:flutter_crypton/pages/monedas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaActual = 0;
  late PageController _pc;
  @override
  void initState() {
    super.initState();
    _pc = PageController(initialPage: paginaActual);
  }

  _setPaginaActual(pagina) {
    setState(() {
      paginaActual = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pc,
        children: const [
          MonedasPage(),
          FavoritasPage(),
          CarteraPage(),
          ConfiguracionesPage(),
        ],
        onPageChanged: _setPaginaActual,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaActual,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Todas'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoritas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Cartera'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
        onTap: (pagina) {
          _pc.animateToPage(
            pagina,
            duration: const Duration(milliseconds: 400),
            curve: Curves.ease,
          );
        },
        backgroundColor: const Color.fromARGB(255, 248, 166, 141),
      ),
    );
  }
}
