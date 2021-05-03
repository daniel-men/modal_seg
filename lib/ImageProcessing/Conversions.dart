

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

Future<ui.Image> convertToUiImage(img.Image image) async {
  var paint = await PaintingBinding.instance!.instantiateImageCodec(img.encodePng(image) as Uint8List);
  final nextFrame = await paint.getNextFrame();
  return nextFrame.image;
}

img.Image? convertByteListToImage(Uint8List bytes) {
  var decodedImage = img.decodeImage(bytes);
  return decodedImage;
}

Future<img.Image> convertImage(ui.Image inputImage) async {
  ByteData bd = (await (inputImage.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
  img.Image image = img.Image.fromBytes(inputImage.width, inputImage.height, bd.buffer.asUint8List());
  return image;
}
/*

Array2d imageToArray(img.Image src) {
  Array2d out = Array2d.fixed(src.width, src.height);
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      out[x][y] = getGrayPixelValue(x, y, src).toDouble();
    }
  }

  return out;
}

img.Image arrayToImage(Array2d src) {
  List<int> bytes = [];
  for (var i = 0; i < src.row; i++) {
    for (var j = 0; j < src.column; j++) {
      int color = src[i][j].toInt();
      bytes.add(img.getColor(color, color, color));
    }    
  }
  return img.Image.fromBytes(src.row, src.column, bytes, format: img.Format.luminance);
}
*/
