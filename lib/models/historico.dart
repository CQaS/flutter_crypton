import 'moneda.dart';

class Historico {
  DateTime dataOperacion;
  String tipoOperacion;
  Moneda moneda;
  double valor;
  double cantidad;

  Historico({
    required this.dataOperacion,
    required this.tipoOperacion,
    required this.moneda,
    required this.valor,
    required this.cantidad,
  });
}
