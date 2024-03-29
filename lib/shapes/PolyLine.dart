import 'package:flutter/material.dart';
import 'package:modal_seg/SelfPainter.dart';
import 'package:modal_seg/shapes/Line.dart';
import 'package:modal_seg/shapes/Shape.dart';
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
  paint(Canvas canvas, Paint paint) {
    paint.strokeWidth = strokeWidth;
    Path path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    //Offset firstPoint = points.first;
    for (Offset point in points) {
      path.lineTo(point.dx, point.dy);
      //Offset pointTranslated = point - firstPoint;
      //path.lineTo(pointTranslated.dx, pointTranslated.dy);
    }

    if (this.closePath != null && this.closePath!) {
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  State<StatefulWidget> createState() => PolyLineState();

  @override
  Set<Tuple2<int, int>> getPointsInShape(num? originalHeight,
      num? originalWidth, num scaledHeight, num scaledWidth,
      {Offset offset = const Offset(0, 0)}) {
    List<Offset> insidePoints = [];

    List<Offset> interpolatedPoints = [];
    for (var i = 0; i < points.length - 1; i++) {
      interpolatedPoints.addAll(getPointsOnLine(points[i], points[i + 1]));
    }

    if (closePath != null && closePath!) {
      insidePoints = getClosedPoints(interpolatedPoints, originalHeight,
          originalWidth, scaledHeight, scaledWidth);
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

    return points;
  }
}

class PolyLineState extends ShapeState {
  List<Widget> buildAnchorPoints() {
    List<Offset> points = (widget as PolyLine).points;
    List<Widget> anchorPoints = [];

    for (var i = 0; i < points.length; i++) {
      Offset point = points[i];
      Widget positioned = Positioned(
          top: point.dy, // - (widget as PolyLine).points.first.dy,
          left: point.dx, // - (widget as PolyLine).points.first.dx,
          child: GestureDetector(
              onPanUpdate: (tapInfo) {
                setState(() {
                  (widget as PolyLine).points[i] += tapInfo.delta;
                });
              },
              child: Container(
                width: widget.strokeWidth * 4,
                height: widget.strokeWidth * 4,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: widget.color),
              )));
      anchorPoints.add(positioned);
    }
    return anchorPoints;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> anchorPoints = buildAnchorPoints();

    Widget painterContainer = 
    /*Positioned(
        top: widget.yPosition,
        left: widget.xPosition,
        child: GestureDetector(
            onPanUpdate: (tapInfo) {
              setState(() {
                widget.xPosition += tapInfo.delta.dx;
                widget.yPosition += tapInfo.delta.dy;
                //widget.hasBeenMoved(tapInfo.delta.dx, tapInfo.delta.dy);
              });
            },
            onPanEnd: (DragEndDetails details) {
              widget.hasBeenMoved();
            },
            child: 
            */Container(
                child: CustomPaint(
              painter: SelfPainter(this),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(50, 255, 0, 0),
                ),
                child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white30),
                    onPressed: () => widget.onDelete(widget)),
              ),
            ));
    //anchorPoints.add(painterContainer);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Positioned(
        top: widget.yPosition,
        left: widget.xPosition,
        child: Stack(children: [Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(children: anchorPoints)), painterContainer]));
    });
  }
}
