import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:modal_seg/shapes/Shape.dart';

class Circle extends Shape {
  final double radius;
  final Offset initialPoint;

  Circle({this.radius, this.initialPoint}) {
    xPosition = initialPoint.dx;
    yPosition = initialPoint.dy;
  }


  @override
  paint(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset(0, 0), radius, paint);
  }

  @override
  State<StatefulWidget> createState() => ShapeState(xPosition, yPosition);

}