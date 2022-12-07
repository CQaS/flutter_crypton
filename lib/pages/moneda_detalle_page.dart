import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_crypton/models/moneda.dart';
import 'package:flutter_crypton/repos/conta_repo.dart';
import 'package:flutter_crypton/widget/grafico_historico.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';

class MonedaDetalles extends StatefulWidget {
  final Moneda moneda;
  const MonedaDetalles({Key? key, required this.moneda}) : super(key: key);

  @override
  State<MonedaDetalles> createState() => _MonedaDetallesState();
}

class _MonedaDetallesState extends State<MonedaDetalles> {
  late NumberFormat real;
  final _form = GlobalKey<FormState>();
  final _valor = TextEditingController();
  double cantidades = 0;
  late ContaRepo conta;
  Widget grafico = Container();
  bool graficoLoad = false;

  getGrafico() {
    if (!graficoLoad) {
      grafico = GraficoHistorico(moneda: widget.moneda);
      graficoLoad = true;
    }
    return grafico;
  }

  _comprar() async {
    if (_form.currentState!.validate()) {
      await conta.comprar(widget.moneda, double.parse(_valor.text));

      Navigator.pop(context);

      //cartelito que sale en la vista principal...
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compra realizada con exito!'),
        ),
      );
    }
  }

  compartirPrecio() {
    final moneda = widget.moneda;
    SocialShare.shareOptions(
        "Compartir precio de ${moneda.nombre} ahora: ${real.format(moneda.precio)}");
  }

  @override
  Widget build(BuildContext context) {
    conta = Provider.of<ContaRepo>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moneda.nombre),
        actions: [
          IconButton(
            onPressed: compartirPrecio,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    widget.moneda.icon,
                    scale: 2.5,
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    widget.moneda.precio.toString(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            getGrafico(),
            (cantidades > 0)
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      child: Text(
                        '$cantidades ${widget.moneda.sigla}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.teal,
                        ),
                      ),
                      margin: const EdgeInsets.only(
                        bottom: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.05),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(bottom: 24),
                  ),
            Form(
              key: _form,
              child: TextFormField(
                controller: _valor,
                style: const TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                  suffix: Text(
                    'Pesos',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (valor) {
                  if (valor!.isEmpty) {
                    return 'Ingresa un valor de compra';
                  } else if (double.parse(valor) < 50) {
                    return 'Compra minima de 50';
                  } else if (double.parse(valor) > conta.saldo) {
                    return 'Usted no tiene saldo suficiente';
                  }
                  return null;
                },
                onChanged: (v) {
                  setState(() {
                    cantidades = (v.isEmpty)
                        ? 0
                        : double.parse(v) / widget.moneda.precio;
                  });
                },
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(top: 24),
              child: ElevatedButton(
                onPressed: _comprar,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.diamond_outlined),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Comprar',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
