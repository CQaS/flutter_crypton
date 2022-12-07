import 'package:flutter/material.dart';
import 'package:flutter_crypton/config/app_setting.dart';
import 'package:flutter_crypton/models/moneda.dart';
import 'package:flutter_crypton/pages/moneda_detalle_page.dart';
import 'package:flutter_crypton/repos/favoritos_repo.dart';
import 'package:flutter_crypton/repos/moneda_repo.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonedasPage extends StatefulWidget {
  const MonedasPage({Key? key}) : super(key: key);

  @override
  State<MonedasPage> createState() => _MonedasPageState();
}

class _MonedasPageState extends State<MonedasPage> {
  List<Moneda> seleccionadas = [];
  late List<Moneda> tabla;
  //final tabla = MonedaRepo.tabla;
  late NumberFormat real;
  late Map<String, String> loc;
  late FavoritosRepo favoritos;
  late MonedaRepo moneda;

  readNumberFormat() {
    loc = context.watch<AppSetting>().localizacion;
    real =
        NumberFormat.currency(locale: loc['localizacion'], name: loc['nombre']);
  }

  changeLenguajeButtom() {
    final local = loc['localizacion'] == 'pt_BR' ? 'en_US' : 'pt_BR';
    final nombre = loc['localizacion'] == 'pt_BR' ? '\$' : 'R\$';

    return PopupMenuButton(
      icon: const Icon(Icons.language),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.swap_vert),
            title: Text('Usar $local'),
            onTap: () {
              context.read<AppSetting>().setLocal(local, nombre);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  appBarDynamic() {
    if (seleccionadas.isEmpty) {
      return AppBar(
        title: const Text('Monedas Crypton'),
        actions: [changeLenguajeButtom()],
      );
    } else {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              seleccionadas = [];
            });
          },
        ),
        title: Text(
          '${seleccionadas.length} Seleccionadas',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey[50],
        iconTheme: const IconThemeData(color: Colors.black87),
      );
    }
  }

  mostrarDetalles(Moneda moneda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MonedaDetalles(moneda: moneda),
      ),
    );
  }

  limpiarSeleccionadas() {
    setState(() {
      seleccionadas = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    //favoritos = Provider.of<FavoritosRepo>(context);
    favoritos = context.watch<FavoritosRepo>();
    moneda = context.watch<MonedaRepo>();
    tabla = moneda.tabla;
    readNumberFormat();

    return Scaffold(
      appBar: appBarDynamic(),
      body: RefreshIndicator(
        onRefresh: () => moneda.checkPrecios(),
        child: ListView.separated(
          itemBuilder: (BuildContext context, int moneda) {
            return ListTile(
              onTap: () => mostrarDetalles(tabla[moneda]),
              onLongPress: () {
                setState(() {
                  (seleccionadas.contains(tabla[moneda]))
                      ? seleccionadas.remove(tabla[moneda])
                      : seleccionadas.add(tabla[moneda]);
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selected: seleccionadas.contains(tabla[moneda]),
              selectedTileColor: Colors.indigo.shade200,
              leading: (seleccionadas.contains(tabla[moneda]))
                  ? const CircleAvatar(
                      child: Icon(Icons.check),
                    )
                  : SizedBox(
                      child: Image.network(tabla[moneda].icon),
                      width: 40,
                    ),
              title: Row(
                children: [
                  Text(
                    tabla[moneda].nombre,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  if (favoritos.lista
                      .any((fav) => fav.sigla == tabla[moneda].sigla))
                    const Icon(Icons.circle, color: Colors.amber, size: 8)
                ],
              ),
              trailing: Text(tabla[moneda].precio.toString()),
            );
          },
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const Divider(),
          itemCount: tabla.length,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: seleccionadas.isNotEmpty
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.star),
              onPressed: () {
                favoritos.saveAll(seleccionadas);
                limpiarSeleccionadas();
              },
              label: const Text(
                'FAVORITOS',
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
