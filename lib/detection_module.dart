import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:image/image.dart' as img;

class DetectionModule {
  late Interpreter interpreter;
  late ImageProcessor imageProcessor;
  late TensorImage inputImage;
  late TensorProcessor outputProcessor;
  late List<String> labels;

  final int inputSize = 640; // Adjust according to your YOLO model

  DetectionModule() {
    initModel();
  }

  Future<void> initModel() async {
    // Load TFLite model
    interpreter = await Interpreter.fromAsset("models/yolov8n.tflite");

    // Image preprocessing: resize + normalize
    imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.NEAREST_NEIGHBOUR))
        .add(NormalizeOp(0, 255)) // Convert 0-255 to 0-1
        .build();

    inputImage = TensorImage(TfLiteType.float32);

    // Output postprocessing: dequantize if needed
    outputProcessor = TensorProcessorBuilder()
        .add(DequantizeOp(0, 1 / 255.0))
        .build();

    // Load labels from assets
    labels = await FileUtil.loadLabels("assets/labels.txt");

    print("Detection Module initialized");
  }

  /// Convert CameraImage to RGB bytes
  TensorImage cameraImageToTensor(CameraImage cameraImage) {
    // Convert YUV420 to RGB image using 'image' package
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final img.Image image = img.Image(width, height);

    final Plane plane = cameraImage.planes[0];
    final Uint8List bytes = plane.bytes;

    // Simple conversion: fill with grayscale for prototype
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = bytes[y * width + x];
        image.setPixelRgba(x, y, pixel, pixel, pixel);
      }
    }

    // Convert to TensorImage
    return TensorImage.fromImage(image);
  }

  /// Run detection on CameraImage
  Future<List<Map<String, dynamic>>> runOnFrame(CameraImage cameraImage) async {
    // Convert to TensorImage
    inputImage = cameraImageToTensor(cameraImage);

    // Preprocess image
    inputImage = imageProcessor.process(inputImage);

    // Prepare output buffer (adjust shape according to your YOLO model)
    TensorBuffer outputBuffer = TensorBufferFloat([1, 25200, 85]);

    // Run inference
    interpreter.run(inputImage.buffer, outputBuffer.buffer);

    // Postprocess output
    outputBuffer = outputProcessor.process(outputBuffer);

    // Parse YOLO detections
    return parseOutput(outputBuffer);
  }

  /// Parse YOLO output to list of detected objects
  List<Map<String, dynamic>> parseOutput(TensorBuffer output) {
    List<Map<String, dynamic>> detections = [];
    final data = output.getDoubleList();

    for (int i = 0; i < data.length; i += 85) {
      double confidence = data[i + 4]; // objectness score
      if (confidence > 0.5) {
        // Bounding box
        double cx = data[i];
        double cy = data[i + 1];
        double w = data[i + 2];
        double h = data[i + 3];

        // Class index
        int classIndex = data
            .sublist(i + 5, i + 85)
            .indexOf(
              data.sublist(i + 5, i + 85).reduce((a, b) => a > b ? a : b),
            );

        detections.add({
          'label': labels[classIndex],
          'confidence': confidence,
          'cx': cx,
          'cy': cy,
          'w': w,
          'h': h,
        });
      }
    }
    return detections;
  }
}
