import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({Key? key}) : super(key: key);

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  List<CameraDescription> camaras = [];
  CameraController? controll;
  XFile? img;
  Size? size;

  @override
  void initState() {
    super.initState();
    _loadCamara();
  }

  _loadCamara() async {
    try {
      camaras = await availableCameras();
      _startCamera();
    } on CameraException catch (e) {
      print(e.description);
    }
  }

  _startCamera() {
    if (camaras.isEmpty) {
      print('Camara not found');
    } else {
      _previewCamara(camaras.first);
    }
  }

  _previewCamara(CameraDescription camara) async {
    final CameraController cameraController = CameraController(
      camara,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controll = cameraController;

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print(e.description);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documento'),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[900],
        child: Center(
          child: _archivoWidget(),
        ),
      ),
      floatingActionButton: (img != null)
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pop(context),
              label: const Text('Finalizar'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _archivoWidget() {
    return Container(
      width: size!.width - 50,
      height: size!.height - (size!.height / 3),
      child: img == null
          ? _camaraPreviewWidget()
          : Image.file(
              File(img!.path),
              fit: BoxFit.contain,
            ),
    );
  }

  _camaraPreviewWidget() {
    final CameraController? cameraController = controll;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text('Camara no disponible');
    } else {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          CameraPreview(controll!),
          _btnCapturaWidget(),
        ],
      );
    }
  }

  _btnCapturaWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: Colors.black.withOpacity(0.5),
        child: IconButton(
          onPressed: sacarFoto,
          icon: const Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  sacarFoto() async {
    final CameraController? cameraController = controll;

    if (cameraController != null && cameraController.value.isInitialized) {
      try {
        XFile file = await cameraController.takePicture();
        if (mounted) setState(() => img = file);
      } on CameraException catch (e) {
        print(e.description);
      }
    }
  }
}
