

import 'package:flutter/material.dart';
import 'package:modal_seg/SelfPainter.dart';
import 'package:tuple/tuple.dart';

abstract class Shape extends StatefulWidget {

  late double xPosition;
  late double yPosition;
  late int timestamp;
  
  paint(Canvas canvas, Paint paint);

  Set<Tuple2<int, int>> getPointsInShape(int? originalHeight, int? originalWidth, int scaledHeight, int scaledWidth);
  void hasBeenMoved() {}
  int createTimeStamp() => DateTime.now().millisecondsSinceEpoch;

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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(10, 20, 20, 0),
              ),
            ),
        )),
      ),
    );
  }
}