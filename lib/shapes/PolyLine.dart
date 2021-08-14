import 'package:flutter/material.dart';
import 'package:modal_seg/shapes/Line.dart';
import 'package:tuple/tuple.dart';

// ignore: must_be_immutable
class PolyLine extends Line {
  final List<Offset> points;
  final Function? onMoved;

  PolyLine(
      {required this.points,
      this.onMoved,
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
            index: index); 

  @override
  Set<Tuple2<int, int>> getPointsInShape(num? originalHeight,
      num? originalWidth, num scaledHeight, num scaledWidth,
      {Offset offset = const Offset(0, 0)}) {

    List<Offset> insidePoints = [];

    List<Offset> interpolatedPoints = [];
    for (var i = 0; i < points.length-1; i++) {
      interpolatedPoints.addAll(getPointsOnLine(points[i], points[i+1]));
    }

    if (closePath != null && closePath!) {
      insidePoints = getClosedPoints(interpolatedPoints, originalHeight, originalWidth, scaledHeight, scaledWidth);
    } else {
      insidePoints = getPoints(interpolatedPoints, offset: offset);
    }

    Set<Tuple2<int, int>> coordinates = pointsToTupleList(insidePoints);
    

    return coordinates;
  }

  List<Offset> getPointsOnLine(Offset point1, Offset point2) {
    List<Offset> points = [];
    if (point1.dx == point2.dx) {
      for (double y = point1.dy; y <= point2.dy; y++) {
        points.add(Offset(point1.dx, y));
      }
    } else {
      if (point2.dx < point1.dx) {
        Offset temp = point1;
        point1 = point2;
        point2 = temp;
      }

      double deltaX = point2.dx - point1.dx;
      double deltaY = point2.dy - point1.dy;
      double error = -1.0;
      double deltaError = (deltaY / deltaX).abs();

      double y = point1.dy;
      for (double x = point1.dx; x <= point2.dx; x++) {
        Offset p = Offset(x, y);
        points.add(p);

        error += deltaError;

        while (error >= 0) {
          y += 1;
          points.add(Offset(x, y));
          error -= 1;
        }
      }
      
    }
    /*
    Offset p2Truncated = Offset(point2.dx.truncateToDouble(), point2.dy.truncateToDouble());
    if (points.last != p2Truncated) {
      int index = points.indexOf(p2Truncated);
      points.removeRange(index + 1, points.length - index - 1);
    }
    */

    return points;
  }
  
  
}
