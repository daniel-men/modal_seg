

import 'package:flutter/material.dart';
import 'package:modal_seg/SelfPainter.dart';
import 'package:tuple/tuple.dart';

abstract class Shape extends StatefulWidget {

  late double xPosition;
  late double yPosition;
  late int timestamp;
  late double strokeWidth;
  late final String imageName;
  late int index;
  late final Function onDelete;
  
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(50, 255, 0, 0),
              ),
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.white30),
                onPressed: () => widget.onDelete(widget.imageName, widget.index)),
            ),
        )),
      ),
    );
  }
}