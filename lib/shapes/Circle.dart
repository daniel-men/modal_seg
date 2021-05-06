

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:modal_seg/shapes/Shape.dart';
import 'package:tuple/tuple.dart';

// ignore: must_be_immutable
class Circle extends Shape {
  final double? radius;
  final Offset? initialPoint;

  Circle({
      this.radius,
      this.initialPoint,
      required String className,
      required Color color,
      required Function onDelete,
      required String imageName,
      required int index,
      int? givenTimestamp}) : super(
        className: className,
        color: color,
        onDelete: onDelete,
        imageName: imageName,
        index: index
      ) {

        
    xPosition = initialPoint!.dx;
    yPosition = initialPoint!.dy;


    if (givenTimestamp == null) {
      timestamp = createTimeStamp();
    } else {
      this.timestamp = givenTimestamp;
    }
  }


  @override
  paint(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset(0, 0), radius!, paint);
  }

  @override
  State<StatefulWidget> createState() => ShapeState();

  @override
  Set<Tuple2<int, int>> getPointsInShape(num? originalHeight, num? originalWidth, num scaledHeight, num scaledWidth) {
    // TODO: implement getPointsInShape
    throw UnimplementedError();
  }

  @override
  Shape copy() {
    // TODO: implement copy
    throw UnimplementedError();
  }

}