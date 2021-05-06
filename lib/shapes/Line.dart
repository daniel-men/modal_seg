import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:modal_seg/shapes/Shape.dart';
import 'package:tuple/tuple.dart';

// ignore: must_be_immutable
class Line extends Shape {
  final List<Offset>? points;
  final Function? onMoved;
  final bool? closePath;
  

  late final List<List<dynamic>?> drawingPoints;

  Line(
      {this.points,
      this.onMoved,
      this.closePath,
      required String className,
      required Color color,
      required Function onDelete,
      required String imageName,
      required int index,
      int? givenTimestamp})
      : super(
            className: className,
            color: color,
            onDelete: onDelete,
            imageName: imageName,
            index: index) {
    if (points != null) {
      xPosition = points!.first.dx;
      yPosition = points!.first.dy;
    }

    if (givenTimestamp == null) {
      timestamp = createTimeStamp();
    } else {
      this.timestamp = givenTimestamp;
    }
  }

  @override
  paint(Canvas canvas, Paint paint) {
    paint.strokeWidth = strokeWidth;
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
    onMoved!(Line(
        className: className,
        color: color,
        points: translatedPoints,
        onMoved: onMoved,
        givenTimestamp: timestamp,
        onDelete: onDelete,
        imageName: imageName,
        index: index));
  }

  @override
  State<StatefulWidget> createState() => ShapeState();

  @override
  Set<Tuple2<int, int>> getPointsInShape(num? originalHeight,
      num? originalWidth, num scaledHeight, num scaledWidth) {
    List<Offset> insidePoints = [];
    if (closePath != null && closePath!) {
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
            insidePoints.add(Offset(tempX / scaledWidth * originalWidth!,
                tempY / scaledHeight * originalHeight!));
          }
          j += 1;
        }
        i += 1;
      }
    } else {
      for (Offset p in points!) {
        insidePoints.add(p);
      }
    }

    Set<Tuple2<int, int>> coordinates = Set();

    for (Offset offset in insidePoints) {
      coordinates.add(Tuple2<int, int>(offset.dx.toInt(), offset.dy.toInt()));
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

  @override
  Shape copy() {
    return Line(
        className: className,
        color: color,
        points: points,
        onMoved: onMoved,
        givenTimestamp: timestamp,
        onDelete: onDelete,
        imageName: imageName,
        index: index)
      ..strokeWidth = strokeWidth;
  }
}
