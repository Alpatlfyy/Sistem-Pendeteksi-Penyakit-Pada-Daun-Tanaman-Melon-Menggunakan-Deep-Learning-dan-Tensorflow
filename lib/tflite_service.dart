import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _interpreter;
  late List<String> _labels;
  late int inputSize;

  static const String modelPath = 'assets/model/model_melon.tflite';
  static const String labelPath = 'assets/model/labels.txt';

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      final labelData = await rootBundle.loadString(labelPath);
      _labels = labelData.split('\n').where((e) => e.isNotEmpty).toList();

      final inputShape = _interpreter!.getInputTensor(0).shape;
      inputSize = inputShape.length == 4 ? inputShape[1] : inputShape[0];

      print("✅ Model berhasil dimuat (${_labels.length} kelas).");
      print("📏 Input tensor shape: $inputShape");
    } catch (e) {
      print("❌ Error memuat model: $e");
      rethrow;
    }
  }

  Float32List _preProcessImage(File imageFile) {
    final img.Image? originalImage =
    img.decodeImage(imageFile.readAsBytesSync());
    if (originalImage == null) throw Exception("Gagal decode gambar");

    final img.Image resized = img.copyResize(
      originalImage,
      width: inputSize,
      height: inputSize,
    );

    final Float32List buffer = Float32List(inputSize * inputSize * 3);
    int i = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        buffer[i++] = pixel.r / 255.0;
        buffer[i++] = pixel.g / 255.0;
        buffer[i++] = pixel.b / 255.0;
      }
    }
    return buffer;
  }

  Future<String> runInference(File imageFile) async {
    if (_interpreter == null) throw Exception("Model belum dimuat.");

    final inputBuffer = _preProcessImage(imageFile);
    final input = inputBuffer.reshape([1, inputSize, inputSize, 3]);

    final outputTensor = _interpreter!.getOutputTensor(0);
    final outputShape = outputTensor.shape;
    final output = List.filled(outputShape.last, 0.0).reshape([1, outputShape.last]);

    _interpreter!.run(input, output);

    final results = List<double>.from(output[0]);
    int maxIndex = 0;
    double maxProb = results[0];

    for (int i = 1; i < results.length; i++) {
      if (results[i] > maxProb) {
        maxProb = results[i];
        maxIndex = i;
      }
    }

    final label = _labels[maxIndex];
    return "🩺 Prediksi: $label\nConfidence: ${(maxProb * 100).toStringAsFixed(2)}%";
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
