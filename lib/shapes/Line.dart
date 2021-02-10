import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:modal_seg/shapes/Shape.dart';

class Line extends Shape {
  final List<Offset> points;

  Line({this.points}) {
    xPosition = points.first.dx;
    yPosition = points.first.dy;
  }

  @override
  paint(Canvas canvas, Paint paint) {
    Path path = Path();
      
      for (Offset point in points) {
        Offset pointTranslated = point - points.first;
        path.lineTo(pointTranslated.dx, pointTranslated.dy);
      }
      
      //canvas.drawLine(points[i]-points.first, points[i + 1]-points.first, paint);
    
    canvas.drawPath(path, paint);
    //canvas.drawRect(path.getBounds(), paint);
    //getPointsInShape(canvas);
  }

  @override
  State<StatefulWidget> createState() => ShapeState(xPosition, yPosition);

  @override
  List<List<dynamic>> getPointsInShape() {
    Path path = Path();
      
      for (Offset point in points) {
        Offset pointTranslated = point - points.first;
        path.lineTo(pointTranslated.dx, pointTranslated.dy);
      }      
    
    Rect boundingBox = path.getBounds();
    boundingBox = boundingBox.translate(points.first.dx, points.first.dy);

    int i = 0;
    int j = 0;
    List<Offset> insidePoints = [];

    while (i < boundingBox.width-1) {
      j = 0;
      while (j < boundingBox.height-1) {
        double tempX = boundingBox.topLeft.dx + i;
        double tempY = boundingBox.topLeft.dy + j;
        Offset tempPoint = Offset(tempX, tempY);
        if (wnPnPoly(tempPoint) != 0) {
          insidePoints.add(tempPoint);
        }
        j += 1;
      }
      i += 1;      
    } 

    /*
    Paint paint = new Paint()
      ..color = Colors.yellow
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPoints(PointMode.points, insidePoints, paint);
    */

    int rows = 2;
    int columns = insidePoints.length;
    var twoDList = List.generate(rows, (i) => []..length = (columns), growable: false);
    int k = 0;
    for (Offset offset in insidePoints) {
      twoDList[0][k] = offset.dx.toInt();
      twoDList[1][k] = offset.dy.toInt();
      k += 1;
    }

    return twoDList;
  }

  double _isLeft(Offset P0, Offset P1, Offset P2) {
    return ((P1.dx - P0.dx) * (P2.dy - P0.dy) - (P2.dx - P0.dx) * (P1.dy - P0.dy));
  }
  
  int wnPnPoly(Offset p) {
    int wn = 0;
    int i = 0;
    int n = points.length -1;

    while (i < n) {
      if (points[i].dy <= p.dy) {
        if (points[i+1].dy > p.dy) {
          if (_isLeft(points[i], points[i+1], p) > 0) {
            wn += 1;
          }
        }
      } else {
        if (points[i+1].dy <= p.dy) {
          if (_isLeft(points[i], points[i+1], p) < 0) {
            wn -= 1;
          }
        }
      }
      i+= 1;
    }

    return wn;
  }

  static List<Offset> prunePoints(List<Offset> points) {
    double minDist = double.infinity;
    int minP1;
    int minP2;
    List<Offset> reversed = points.reversed.toList();
    for (int i in Iterable<int>.generate(points.length)) {
      Offset p1 = points[i];
      for (int j in Iterable<int>.generate(points.length-i-10)) {
        Offset p2 = reversed[j];
        double dist = (p1 - p2).distanceSquared;
        if (dist < minDist) {
          minDist = dist;
          minP1 = i;
          minP2 = j;
        }
      }
    }
    return points.sublist(minP1, points.length-minP2);
  }
}
