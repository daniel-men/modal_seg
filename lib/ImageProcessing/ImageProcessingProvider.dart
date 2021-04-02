import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:modal_seg/ImageProcessing/Conversions.dart';

class ImageProcessingProvider {
  final ui.Image originalImage;
  late img.Image _convertedImage;
  List<Function>? operations = [];

  ImageProcessingProvider(this.originalImage, {List<Function>? operations}) {
    _initialProcessing(operations);
  }

  Future<void> _initialProcessing(List<Function>? operations) async {
    await _convertToImgImage();
    if (operations != null) {
      this.operations = operations;
      applyOperations();
    }
  }

  Future<void> applyOperations() async {
    for (Function f in operations!) {
      _convertedImage = f(_convertedImage);
    }
  }

  void addOp(Function f) {
    operations!.add(f);
  }

  Future<void> _convertToImgImage() async {
    _convertedImage = await convertImage(originalImage);
  }
  

  Future<ui.Image> getImage() async {
    if (operations!.isEmpty) {
      return originalImage;
    }
    return convertToUiImage(_convertedImage);
  }




}