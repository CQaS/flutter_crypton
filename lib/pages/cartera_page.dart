import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crypton/config/app_setting.dart';
import 'package:flutter_crypton/models/posicion.dart';
import 'package:flutter_crypton/repos/conta_repo.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CarteraPage extends StatefulWidget {
  const CarteraPage({Key? key}) : super(key: key);

  @override
  State<CarteraPage> createState() => _CarteraPageState();
}

class _CarteraPageState extends State<CarteraPage> {
  int index = 0;
  double totalCartera = 0;
  double saldo = 0;
  late NumberFormat real;
  late ContaRepo conta;
  String graficoLabel = '';
  double graficoValor = 0;
  List<Posicion> cartera = [];

  @override
  Widget build(BuildContext context) {
    conta = context.watch<ContaRepo>();
    final loc = context.read<AppSetting>().localizacion;
    NumberFormat real =
        NumberFormat.currency(locale: loc['locale'], name: loc['name']);
    saldo = conta.saldo;

    setTotalCartera();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 48, bottom: 8),
              child: Text(
                'Valor de la Cartera',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Text(
              real.format(totalCartera),
              style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.5),
            ),
            _loadGraf(),
            _loadHistorico(),
          ],
        ),
      ),
    );
  }

  setTotalCartera() {
    final carteraList = conta.cartera;
    setState(() {
      totalCartera = conta.saldo;
      for (var pos in carteraList) {
        totalCartera = pos.moneda.precio * pos.cantidad;
      }
    });
  }

  setGraficoDados(int index) {
    if (index < 0) return;
    if (index == cartera.length) {
      graficoLabel = 'Saldo';
      graficoValor = conta.saldo;
    } else {
      graficoLabel = cartera[index].moneda.nombre;
      graficoValor = cartera[index].moneda.precio * cartera[index].cantidad;
    }
  }

  loadCartera() {
    setGraficoDados(index);
    cartera = conta.cartera;
    final tamanioLista = cartera.length + 1;

    return List.generate(tamanioLista, (i) {
      final isTouched = i == index;
      final isSaldo = i == tamanioLista - 1;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radio = isTouched ? 60.0 : 50.0;
      final color = isTouched ? Colors.tealAccent : Colors.tealAccent.shade400;
      double porcentaje = 0;

      if (!isSaldo) {
        porcentaje =
            cartera[i].moneda.precio * cartera[i].cantidad / totalCartera;
      } else {
        porcentaje = (conta.saldo > 0) ? conta.saldo : 0;
      }
      porcentaje *= 100;

      return PieChartSectionData(
        color: color,
        value: porcentaje,
        title: '${porcentaje.toStringAsFixed(0)}%',
        radius: radio,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );
    });
  }

  /* setGraficoDados(index) {
    if (index < 0) return;

    if (index == carteira.length) {
      graficoLabel = 'Saldo';
      graficoValor = conta.saldo;
    } else {
      graficoLabel = carteira[index].moeda.nome;
      graficoValor = carteira[index].moeda.preco * carteira[index].quantidade;
    }
  }
} */

  _loadGraf() {
    return (conta.saldo <= 0)
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: 110,
                    sections: loadCartera(),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          index = pieTouchResponse!
                              .touchedSection!.touchedSectionIndex;
                          setGraficoDados(index);
                        });
                      },
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    graficoLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    real.format(graficoValor),
                    style: const TextStyle(
                      fontSize: 28,
                    ),
                  )
                ],
              ),
            ],
          );
  }

  _loadHistorico() {
    final historico = conta.historico;
    final date = DateFormat('dd/mm/yyy - hh:mm');
    List<Widget> widgets = [];

    for (var operacion in historico) {
      widgets.add(ListTile(
        title: Text(operacion.moneda.nombre),
        subtitle: Text(date.format(operacion.dataOperacion)),
        trailing:
            Text(real.format((operacion.moneda.precio * operacion.cantidad))),
      ));
      widgets.add(Divider());
    }

    return Column(
      children: widgets,
    );
  }
}
