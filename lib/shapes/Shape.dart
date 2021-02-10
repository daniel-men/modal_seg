import 'package:flutter/material.dart';
import 'package:modal_seg/SelfPainter.dart';

abstract class Shape extends StatefulWidget {

  double xPosition;
  double yPosition;
  paint(Canvas canvas, Paint paint);

  List<List<dynamic>> getPointsInShape() {}

}

class ShapeState extends State<Shape> {
  double xPosition;
  double yPosition;

  ShapeState(double xPosition, double yPosition) {
    this.xPosition = xPosition;
    this.yPosition = yPosition;
  }

  paint(Canvas canvas, Paint paint) {
    widget.paint(canvas, paint);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition,
      left: xPosition,
      child: GestureDetector(
        
        onPanUpdate: (tapInfo) {
          setState(() {
            xPosition += tapInfo.delta.dx;
            yPosition += tapInfo.delta.dy;
          });
          widget.xPosition = xPosition;
          widget.yPosition = yPosition;
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