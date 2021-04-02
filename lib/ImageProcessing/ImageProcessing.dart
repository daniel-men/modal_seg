

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:modal_seg/ImageProcessing/ArrayOps.dart';
import 'package:modal_seg/ImageProcessing/Conversions.dart';
//import 'package:scidart/numdart.dart';
import 'package:tuple/tuple.dart';

enum DIRECTION {
  xDirection,
  yDirection,
  both
}

int getGrayPixelValue(int x, int y, img.Image image) {
  int pixelEncoded = image.getPixelSafe(x, y);
  return img.getLuminance(pixelEncoded);
}

Future<List<List<dynamic>?>> snapToBlack(ui.Image inputImage, Set<Tuple2<int, int>> points) async {
  img.Image image = await convertImage(inputImage);
  image = img.copyResize(image, width: 256, height: 256);
  image = img.gaussianBlur(image, 1);

  List<Tuple2<int, int>> pointsAsList = points.toList();
  List<List<dynamic>?> newPoints = [];
  List<int> offsets = [for(var i=-3; i<=3; i+=1) i];
  

  for (var i = 0; i < pointsAsList.length; i++) {
    int x = pointsAsList[i].item1;
    int y = pointsAsList[i].item2;
    
    int pixel = getGrayPixelValue(x, y, image);
    int newIndex = x;
    for (var j in offsets) {
      int tempIndex = x+j;
      int p = getGrayPixelValue(tempIndex, y, image);
      if (p < pixel) {
        newIndex = tempIndex;
        pixel = p;
      }
    }

    newPoints.add(pointsAsList[i].withItem1(newIndex).toList());
  }


  //return newPoints;
  return correctConnectivity(newPoints, image);
}

List<List<dynamic>?> correctConnectivity(List<List<dynamic>?> points, img.Image image) {
  for (var i = 1; i < points.length; i++) {
    if (!isConnected(points[i-1]!, points[i]!)) {
      int diff = points[i]![1] - points[i-1]![1];
      if (diff > 1) {
        for (var j = 1; j < diff; j++) {
          List<dynamic>? newPoint = findDarkestPixel(getLowerPointNeighbours(points[i-1]![0], points[i-1]![1]+j), image);
          points.insert(i+j, newPoint);
        }
        
      }
      List<dynamic>? newPoint = findDarkestPixel(getLowerPointNeighbours(points[i-1]![0], points[i-1]![1]), image);
      points[i] = newPoint;
      if (i > 1) {
        i = i+diff;
      }
    }
  }
  return points;
}

List<dynamic>? findDarkestPixel(List<List<dynamic>> pixels, img.Image image) {
  int darkest = 256;
  List<dynamic>? point;
  for (var i = 0; i < pixels.length; i++) {
    int pixel = getGrayPixelValue(pixels[i][0], pixels[i][1], image);
    if (pixel < darkest) {
      darkest = pixel;
      point = pixels[i];
    }
  }
  return point;
}

List<List<dynamic>> getLowerPointNeighbours(dynamic x, dynamic y) {
  //return [[x, y+1], [x-1, y], [x+1, y], [x-1, y+1], [x+1, y+1]];
  return [[x, y+1], [x-1, y+1], [x+1, y+1]];
}

bool isConnected(List<dynamic> point1, List<dynamic> point2) {
  var x1 = point1[0];
  var x2 = point2[0];
  var y1 = point1[1];
  var y2 = point2[1];

  if ([x1-1, x1, x1+1].contains(x2) && [y1-1, y1, y1+1].contains(y2)) {
    return true;
  }

  return false;
}

img.Image sobel(img.Image src) {
  return img.sobel(src);
}

img.Image gaussianBlur(img.Image src) {
  return img.gaussianBlur(src, 1);
}

Future<ui.Image> applySobel(Uint8List bytes, {num amount = 1.0}) async {
  img.Image image = convertByteListToImage(bytes)!;
  var edgeImage = img.sobel(image, amount: amount);
  return convertToUiImage(edgeImage);
}

Future<ui.Image> applySobelUI(ui.Image src, {num amount = 1.0}) async {
  img.Image image = await convertImage(src);
  image = img.gaussianBlur(image, 2);
  return convertToUiImage(img.sobel(image, amount: amount));
}

Future<ui.Image> applyGaussian(ui.Image imageIn, {num radius = 1.0}) async {
  img.Image image = await convertImage(imageIn);
  img.Image blurredImage = img.gaussianBlur(image, radius as int);
  return convertToUiImage(blurredImage);
}

int calculateGradient(int x, int y, img.Image image, DIRECTION direction) {
  late int p;
  late int p1;
  if (direction == DIRECTION.xDirection) {
    p = getGrayPixelValue(x+1, y, image);
    p1 = getGrayPixelValue(x-1, y, image);
  } else if(direction == DIRECTION.yDirection) {
    p = getGrayPixelValue(x, y+1, image);
    p1 = getGrayPixelValue(x, y-1, image);
  } else {

  }  
  return ((p - p1) ~/ 2);
}
/*
List<Array2d?> calculateGradients(Array2d src, {DIRECTION direction = DIRECTION.both}) {
  final Array2d fixed2 = Array2d.fixed(src.row, src.column, initialValue: 2);
  
  Array2d? dX;
  Array2d? dY;
  if (direction == DIRECTION.xDirection || direction == DIRECTION.both) { 
    Array2d tempSrc = padArray(src, direction: DIRECTION.xDirection)!;
    dX = Array2d.empty();
    for (var i = 1; i < tempSrc.row-1; i++) {
      dX.add((tempSrc[i+1] - tempSrc[i-1]));
    }
    dX = dX / fixed2;
  }
  if (direction == DIRECTION.yDirection || direction == DIRECTION.both) {
    
    Array2d tempSrc = padArray(transpose(src), direction: DIRECTION.xDirection)!;
    dY = Array2d.empty();
    for (var i = 1; i < tempSrc.row-1; i++) {
      dY.add((tempSrc[i+1] - tempSrc[i-1]));
    }
    dY = dY / fixed2;
    //dY = transpose(dY);
  }

  return [dX, dY];
}

img.Image calculateGradientImage(img.Image image, {DIRECTION direction = DIRECTION.xDirection, int order = 1}) {
  img.Image gradientImage = img.Image.from(image);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      int gradientPixel = calculateGradient(x, y, image, direction);
      gradientImage.setPixelRgba(x, y, gradientPixel, gradientPixel, gradientPixel);
    }
  }

  if (order > 1) {
    return calculateGradientImage(gradientImage, direction: direction, order: order - 1);
  }

  return gradientImage;
}

Future<ui.Image> calculateGradientImageUI(ui.Image src, {DIRECTION direction = DIRECTION.xDirection, int order = 1}) async{
  img.Image image = await convertImage(src);
  //return convertToUiImage(img.normalize(calculateGradientImage(image), 0, 255));
  Array2d imageAsArray = imageToArray(image);
  List<Array2d?> gradients = calculateGradients(imageAsArray);
  
  return convertToUiImage(arrayToImage(normalize(gradients[1]!, 0, 255)));
} 

calculateHessianMatrix(img.Image image) {
  Array2d imageAsArray = imageToArray(image);
  List<Array2d?> gradients = calculateGradients(imageAsArray);
}
*/
