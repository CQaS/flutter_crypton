import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_crypton/config/app_setting.dart';
import 'package:flutter_crypton/repos/conta_repo.dart';
import 'package:flutter_crypton/services/auth_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'document_page.dart';

class ConfiguracionesPage extends StatefulWidget {
  const ConfiguracionesPage({Key? key}) : super(key: key);

  @override
  State<ConfiguracionesPage> createState() => _ConfiguracionesPageState();
}

class _ConfiguracionesPageState extends State<ConfiguracionesPage> {
  XFile? comprobante;
  @override
  Widget build(BuildContext context) {
    final conta = context.watch<ContaRepo>();
    final loc = context.read<AppSetting>().localizacion;
    NumberFormat real =
        NumberFormat.currency(locale: loc['locale'], name: loc['name']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Config'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              title: const Text('Saldo'),
              subtitle: Text(
                real.format(conta.saldo),
                style: const TextStyle(fontSize: 25, color: Colors.indigo),
              ),
              trailing: IconButton(
                onPressed: _upDateSaldo,
                icon: const Icon(Icons.edit),
              ),
            ),
            const Divider(),
            //CAMARA
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Escanea DNI'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DocumentPage(),
                      fullscreenDialog: true)),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.attach_file),
              title: Text('Enviar algo'),
              onTap: seleccionarAlgo,
              trailing: comprobante != null
                  ? Image.file(File(comprobante!.path))
                  : null,
            ),
            const Divider(),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: OutlinedButton(
                    onPressed: () => context.read<AuthServices>().logout(),
                    style: OutlinedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Salir de la App',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  seleccionarAlgo() async {
    final ImagePicker picker = ImagePicker();

    try {
      XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) setState(() => comprobante = file);
    } catch (e) {
      print(e);
    }
  }

  _upDateSaldo() async {
    final form = GlobalKey<FormState>();
    final valor = TextEditingController();
    final conta = context.read<ContaRepo>();

    valor.text = conta.saldo.toString();

    AlertDialog alert = AlertDialog(
      title: const Text('Actualizar el Saldo'),
      content: Form(
        key: form,
        child: TextFormField(
          controller: valor,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'\d+\.?\d*')),
          ],
          validator: (value) {
            if (value!.isEmpty) return 'Ingrese valor del saldo';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR')),
        TextButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                conta.setSaldo(double.parse(valor.text));
                Navigator.pop(context);
              }
            },
            child: const Text('GUARDAR')),
      ],
    );

    showDialog(context: context, builder: (context) => alert);
  }
}
