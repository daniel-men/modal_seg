

import 'package:flutter/material.dart';
import 'package:modal_seg/SelfPainter.dart';
import 'package:tuple/tuple.dart';

// ignore: must_be_immutable
abstract class Shape extends StatefulWidget {

  late double xPosition;
  late double yPosition;
  late double strokeWidth = 1.0;
  late final String imageName;
  late int index;
  late final Function onDelete;
  late final String className;
  late final Color color;
  late final int timestamp;

  Shape({
    required this.className,
    required this.color,
    required this.onDelete,
    required this.imageName,
    required this.index});
  
  paint(Canvas canvas, Paint paint);

  Set<Tuple2<int, int>> getPointsInShape(num? originalHeight, num? originalWidth, num scaledHeight, num scaledWidth, {Offset offset=const Offset(0, 0)});
  void hasBeenMoved() {}
  int createTimeStamp() => DateTime.now().millisecondsSinceEpoch;
  Shape copy();

  Offset roundOffset(Offset offset) => Offset(offset.dx.truncateToDouble(), offset.dy.truncateToDouble());

  List<Offset> applyThickness(List<Offset> points) {
    List<Offset> dilatedPoints = [];
    for (Offset point in points) {
      dilatedPoints.addAll(dilation(point));
    }

    return dilatedPoints.toSet().toList();
  }

  List<Offset> dilation(Offset point) {
    return [
      point,
      Offset(point.dx - 1, point.dy - 1),
      Offset(point.dx - 1, point.dy),
      Offset(point.dx, point.dy - 1),
      Offset(point.dx - 1, point.dy + 1),
      Offset(point.dx + 1, point.dy - 1),
      Offset(point.dx + 1, point.dy + 1),
      Offset(point.dx + 1, point.dy),
      Offset(point.dx, point.dy + 1),
    ];
  }

}

class ShapeState extends State<Shape> {

  

  paint(Canvas canvas, Paint paint) {
    widget.paint(canvas, paint);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
        child: Container(
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
        )),
      ),
    );
  }
}