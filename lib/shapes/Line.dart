

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:modal_seg/ImageProcessing/ImageProcessing.dart';
import 'package:modal_seg/shapes/Shape.dart';
import 'package:tuple/tuple.dart';
import 'dart:ui' as ui;


class Line extends Shape {
  final List<Offset>? points;
  final Function? onMoved;
  final bool? closePath;
  late final int timestamp;
  final ui.Image? image;

  late final List<List<dynamic>?> drawingPoints;

  Line({this.points, this.onMoved, this.closePath, this.image, int? givenTimestamp}) {
    if (points != null) {
      xPosition = points!.first.dx;
      yPosition = points!.first.dy;
    }

    if (givenTimestamp == null) {
      timestamp = createTimeStamp();
    } else {
      this.timestamp = givenTimestamp;
    }
    
    //getDrawingPoints();

  }


  getDrawingPoints() async {
    drawingPoints = await snapToBlack(image!, getPointsInShape(1000, 1000, 256, 256));
  }

  @override
  paint(Canvas canvas, Paint paint) {
    Path path = Path();

    for (Offset point in points!) {
      Offset pointTranslated = point - points!.first;
      path.lineTo(pointTranslated.dx, pointTranslated.dy);
    }

    /*
    for (List<dynamic>? p in drawingPoints) {
      path.lineTo(p![0] - xPosition, p[1]! - yPosition);
    }
    */

    if (this.closePath != null && this.closePath!) {
      path.close();
    }
    
    canvas.drawPath(path, paint);
    //canvas.drawRect(path.getBounds(), paint);
    //getPointsInShape(canvas);
  }

  @override
  void hasBeenMoved() {
    double deltaX = xPosition - points!.first.dx;
    double deltaY = yPosition - points!.first.dy;
    List<Offset> translatedPoints = [];
    for (Offset p in this.points!) {
      translatedPoints.add(p.translate(deltaX, deltaY));
    }
    onMoved!(Line(points: translatedPoints, onMoved: onMoved, givenTimestamp: timestamp));
  }

  @override
  State<StatefulWidget> createState() => ShapeState();

  @override
  Set<Tuple2<int, int>> getPointsInShape(int? originalHeight, int? originalWidth, int scaledHeight, int scaledWidth) {
    List<Offset> insidePoints = [];
    if(closePath != null && closePath!) {
      Path path = Path();

      for (Offset point in points!) {
        Offset pointTranslated = point - points!.first;
        path.lineTo(pointTranslated.dx, pointTranslated.dy);
      }

      Rect boundingBox = path.getBounds();
      boundingBox = boundingBox.translate(points!.first.dx, points!.first.dy);

      int i = 0;
      int j = 0;
      

      while (i < boundingBox.width - 1) {
        j = 0;
        while (j < boundingBox.height - 1) {
          double tempX = boundingBox.topLeft.dx + i;
          double tempY = boundingBox.topLeft.dy + j;
          Offset tempPoint = Offset(tempX, tempY);
          if (wnPnPoly(tempPoint) != 0) {
            insidePoints.add(Offset(tempX / scaledWidth * originalWidth!, tempY / scaledHeight * originalHeight!));
          }
          j += 1;
        }
        i += 1;
      }
    } else {
      for (Offset p in points!) {
        insidePoints.add(p);
        //insidePoints.add(Offset(p.dx / scaledWidth * originalWidth, p.dy / scaledHeight * originalHeight));
      }
    }


    //int rows = 2;
    //int columns = insidePoints.length;
    Set<Tuple2<int, int>> coordinates = Set();


    //var twoDList =
      //  List.generate(rows, (i) => []..length = (columns), growable: false);
    //int k = 0;
    for (Offset offset in insidePoints) {
      coordinates.add(Tuple2<int, int>(offset.dx.toInt(), offset.dy.toInt()));
      //twoDList[0][k] = offset.dx.toInt();
      //twoDList[1][k] = offset.dy.toInt();
      //k += 1;
    }

    return coordinates;
  }

  double _isLeft(Offset p0, Offset p1, Offset p2) {
    return ((p1.dx - p0.dx) * (p2.dy - p0.dy) -
        (p2.dx - p0.dx) * (p1.dy - p0.dy));
  }

  int wnPnPoly(Offset p) {
    int wn = 0;
    int i = 0;
    int n = points!.length - 1;

    while (i < n) {
      if (points![i].dy <= p.dy) {
        if (points![i + 1].dy > p.dy) {
          if (_isLeft(points![i], points![i + 1], p) > 0) {
            wn += 1;
          }
        }
      } else {
        if (points![i + 1].dy <= p.dy) {
          if (_isLeft(points![i], points![i + 1], p) < 0) {
            wn -= 1;
          }
        }
      }
      i += 1;
    }

    return wn;
  }

  static List<Offset> prunePoints(List<Offset> points) {
    double minDist = double.infinity;
    late int minp1;
    late int minp2;
    List<Offset> reversed = points.reversed.toList();
    for (int i in Iterable<int>.generate(points.length)) {
      Offset p1 = points[i];
      for (int j in Iterable<int>.generate(points.length - i - 10)) {
        Offset p2 = reversed[j];
        double dist = (p1 - p2).distanceSquared;
        if (dist < minDist) {
          minDist = dist;
          minp1 = i;
          minp2 = j;
        }
      }
    }
    return points.sublist(minp1, points.length - minp2);
  }
}
