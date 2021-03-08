import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:modal_seg/shapes/Shape.dart';

class Rectangle extends Shape {
  final Rect rect;

  Rectangle(this.rect) {
    xPosition = rect.center.dx;
    yPosition = rect.center.dy;
  }


  @override
  paint(Canvas canvas, Paint paint) {
    canvas.drawRect(rect, paint);
  }

  @override
  State<StatefulWidget> createState() => ShapeState();
  
}