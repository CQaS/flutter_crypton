import 'package:flutter/material.dart';
import 'package:flutter_crypton/repos/favoritos_repo.dart';
import 'package:flutter_crypton/widget/moneda_card.dart';
import 'package:provider/provider.dart';

class FavoritasPage extends StatefulWidget {
  const FavoritasPage({Key? key}) : super(key: key);

  @override
  State<FavoritasPage> createState() => _FavoritasPageState();
}

class _FavoritasPageState extends State<FavoritasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monedas Favoritas'),
      ),
      body: Container(
        color: Colors.indigo.withOpacity(0.05),
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(12),
        child: Consumer<FavoritosRepo>(
          builder: (context, favoritos, child) {
            return favoritos.lista.isEmpty
                ? const ListTile(
                    leading: Icon(Icons.star),
                    title: Text('No tienes Monedas Favoritas'),
                  )
                : ListView.builder(
                    itemCount: favoritos.lista.length,
                    itemBuilder: (_, i) {
                      return MonedaCard(moneda: favoritos.lista[i]);
                    },
                  );
          },
        ),
      ),
    );
  }
}
