

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/shapes/Shape.dart';

class SelfPainter extends CustomPainter {

  final ShapeState shape;

  SelfPainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
      Paint paint = new Paint()
      ..color = shape.widget.color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = shape.widget.strokeWidth
      ..style = PaintingStyle.stroke;
      shape.paint(canvas, paint);
    }
  
    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
      return true;
  }

}