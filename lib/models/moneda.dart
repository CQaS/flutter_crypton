/* class Moneda {
  String icon;
  String nombre;
  String sigla;
  double precio;

  Moneda({
    required this.icon,
    required this.nombre,
    required this.sigla,
    required this.precio,
  });
} */

class Moneda {
  String baseId;
  String icon;
  String nombre;
  String sigla;
  double precio;
  DateTime timestamp;
  double cambioHora;
  double cambioDia;
  double cambioSemana;
  double cambioMes;
  double cambioAnio;
  double cambioPeriodoTotal;

  Moneda({
    required this.baseId,
    required this.icon,
    required this.nombre,
    required this.sigla,
    required this.precio,
    required this.timestamp,
    required this.cambioHora,
    required this.cambioDia,
    required this.cambioSemana,
    required this.cambioMes,
    required this.cambioAnio,
    required this.cambioPeriodoTotal,
  });
}
