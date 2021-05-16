import 'package:flutter/src/widgets/framework.dart';
import 'dart:ui';

import 'package:modal_seg/shapes/Shape.dart';
import 'package:tuple/tuple.dart';

class PolyLine extends Shape {
  final List<Offset>? points;
  final Function? onMoved;

  PolyLine({this.points,
      this.onMoved,
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
      if (givenTimestamp == null) {
        timestamp = createTimeStamp();
      } else {
        this.timestamp = givenTimestamp;
      }
      }

  @override
  Shape copy() {
    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  @override
  Set<Tuple2<int, int>> getPointsInShape(num? originalHeight, num? originalWidth, num scaledHeight, num scaledWidth) {
      // TODO: implement getPointsInShape
      throw UnimplementedError();
    }
  
    @override
    paint(Canvas canvas, Paint paint) {
    // TODO: implement paint
    throw UnimplementedError();
  }
  
}