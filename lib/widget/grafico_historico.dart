import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crypton/config/app_setting.dart';
import 'package:flutter_crypton/models/moneda.dart';
import 'package:flutter_crypton/repos/moneda_repo.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GraficoHistorico extends StatefulWidget {
  Moneda moneda;
  GraficoHistorico({Key? key, required this.moneda}) : super(key: key);

  @override
  State<GraficoHistorico> createState() => _GraficoHistoricoState();
}

enum Periodo { hora, dia, semana, mes, anio, total }

class _GraficoHistoricoState extends State<GraficoHistorico> {
  List<Color> colores = [Color(0xFF3F5181)];
  Periodo periodo = Periodo.hora;
  List<Map<String, dynamic>> historico = [];
  List datosCompletos = [];
  List<FlSpot> datosGrafico = [];
  double maxX = 0;
  double maxY = 0;
  double minY = 0;
  ValueNotifier<bool> load = ValueNotifier(false);
  late MonedaRepo repo;
  late Map<String, String> loc;
  late NumberFormat real;

  setDatos() async {
    load.value = false;
    datosGrafico = [];

    if (historico.isEmpty)
      historico = await repo.getHistoricoMoneda(widget.moneda);

    datosCompletos = historico[periodo.index]['prices'];
    datosCompletos = datosCompletos.reversed.map((item) {
      double precio = double.parse(item[0]);
      int time = int.parse(item[1].toString() + '000');
      return [precio, DateTime.fromMillisecondsSinceEpoch(time)];
    }).toList();

    maxX = datosCompletos.length.toDouble();
    maxY = 0;
    minY = double.infinity;

    for (var item in datosCompletos) {
      maxY = item[0] > maxY ? item[0] : maxY;
      minY = item[0] > minY ? item[0] : minY;
    }

    for (int i = 0; i < datosCompletos.length; i++) {
      datosGrafico.add(FlSpot(
        i.toDouble(),
        datosCompletos[i][0],
      ));
    }
    load.value = true;
  }

  LineChartData getChartData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
            spots: datosGrafico,
            isCurved: true,
            color: const Color(0xFF3F5181),
            barWidth: 2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
                show: true, color: const Color(0xFF3F5181).withOpacity(0.15)))
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: const Color.fromARGB(255, 14, 14, 17),
          getTooltipItems: (data) {
            return data.map(
              (item) {
                final date = getDate(item.spotIndex);
                return LineTooltipItem(
                  real.format(item.y),
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                        text: '\n $date',
                        style: TextStyle(
                            fontSize: 12, color: Colors.white.withOpacity(.5))),
                  ],
                );
              },
            ).toList();
          },
        ),
      ),
    );
  }

  getDate(int index) {
    DateTime date = datosCompletos[index][1];
    if (periodo != Periodo.anio && periodo != Periodo.total)
      return DateFormat('dd/mm - hh:mm').format(date);
    else
      return DateFormat('dd/mm/y').format(date);
  }

  chartButtom(Periodo p, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: () => setState(() => periodo = p),
        child: Text(label),
        style: (periodo != p)
            ? ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.grey),
              )
            : ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                Colors.indigo[50],
              )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    repo = context.read<MonedaRepo>();
    loc = context.read<AppSetting>().localizacion;
    real =
        NumberFormat.currency(locale: loc['localizacion'], name: loc['nombre']);
    setDatos();

    return Container(
      child: AspectRatio(
        aspectRatio: 2,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  chartButtom(Periodo.hora, '1h'),
                  chartButtom(Periodo.dia, '24h'),
                  chartButtom(Periodo.semana, 'Sem'),
                  chartButtom(Periodo.mes, 'Mes'),
                  chartButtom(Periodo.anio, 'Año'),
                  chartButtom(Periodo.total, 'Todo'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: ValueListenableBuilder(
                  valueListenable: load,
                  builder: (context, bool isLoad, _) {
                    return (isLoad)
                        ? LineChart(
                            getChartData(),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
