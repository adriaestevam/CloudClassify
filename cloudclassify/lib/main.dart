import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Classifier App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageClassifierPage(),
    );
  }
}

class ImageClassifierPage extends StatefulWidget {
  @override
  _ImageClassifierPageState createState() => _ImageClassifierPageState();
}

class _ImageClassifierPageState extends State<ImageClassifierPage> {
  File? _image;
  String _classificationResult = "Selecciona una imagen para clasificar";
  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Cargar el modelo
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('1.tflite');
    } catch (e) {
      print("Error al cargar el modelo: $e");
    }
  }

  // Seleccionar una imagen usando FilePicker
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _image = File(result.files.single.path!);
        _classificationResult = "Clasificando...";
        _classifyImage();
      });
    }
  }

  // Clasificación de la imagen
  Future<void> _classifyImage() async {
    if (_image == null || _interpreter == null) return;

    // Leer la imagen y convertirla a un formato adecuado para el modelo
    Uint8List imageBytes = await _image!.readAsBytes();
    // Aquí iría el procesamiento de la imagen (redimensionarla, normalizarla, etc.) según el modelo

    // Este es solo un ejemplo de cómo se realiza la inferencia, deberías ajustarlo a la entrada esperada por tu modelo
    var input = imageBytes; // Procesa según la entrada requerida por el modelo
    var output = List.filled(1, 0).reshape([1, 1]);

    try {
      _interpreter!.run(input, output);
      setState(() {
        _classificationResult = "Resultado: ${output[0][0]}"; // Ajusta el resultado a tu salida
      });
    } catch (e) {
      setState(() {
        _classificationResult = "Error al clasificar la imagen: $e";
      });
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clasificación de Imágenes"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image != null
                  ? Image.file(
                      _image!,
                      height: 200,
                    )
                  : Text(
                      "No se ha seleccionado ninguna imagen",
                      style: TextStyle(fontSize: 18),
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Seleccionar Imagen de la Galería"),
              ),
              SizedBox(height: 20),
              Text(
                _classificationResult,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
