/* import 'package:flutter_crypton/models/moneda.dart';
import 'package:hive/hive.dart';

class MonedaHiveAdapter extends TypeAdapter<Moneda> {
  @override
  final typeId = 0;

  @override
  Moneda read(BinaryReader reader) {
    return Moneda(
      icon: reader.readString(),
      nombre: reader.readString(),
      sigla: reader.readString(),
      precio: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Moneda obj) {
    writer.writeString(obj.icon);
    writer.writeString(obj.nombre);
    writer.writeString(obj.sigla);
    writer.writeDouble(obj.precio);
  }
}
 */