

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:modal_seg/shapes/Shape.dart';
import 'package:tuple/tuple.dart';

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

  @override
  Set<Tuple2<int, int>> getPointsInShape(int? originalHeight, int? originalWidth, int scaledHeight, int scaledWidth) {
    // TODO: implement getPointsInShape
    throw UnimplementedError();
  }

  @override
  Shape copy() {
    // TODO: implement copy
    throw UnimplementedError();
  }
  
}