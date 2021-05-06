

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShapePainter extends CustomPainter {
  final List<Offset> points;
  final String mode;
  final ui.Image? image;
  final double strokeWidth;
  final Color activeColor;

  ShapePainter(this.points, this.mode, this.image, this.strokeWidth, this.activeColor);

  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = activeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    if (image != null) {      
      double top = size.height / 2 - 128;
      double left = size.width / 2 - 128;

      paintImage(canvas: canvas, rect: Rect.fromLTRB(left, top, left+256, top+256), image: image!, fit: BoxFit.scaleDown, repeat: ImageRepeat.noRepeat, scale: 1.0);
    }
    drawCurrent(canvas, paint);
  }


  @override
  bool shouldRepaint(ShapePainter oldDelegate) {
    return oldDelegate.points != points;
  }

  drawCurrent(Canvas canvas, Paint paint) {
    if (points.isEmpty) {
      return;
    }

    switch (mode) {
      case "Circle":
          double radius = sqrt(
              pow(points.last.dx - points.first.dx, 2) +
                  pow(points.last.dy - points.first.dy, 2));
          canvas.drawCircle(points.first, radius, paint);
        
        break;
      case "Line":
        for (var i = 0; i < points.length - 1; i++) {
          canvas.drawLine(points[i], points[i + 1], paint);
        }        
        break;
      case "Rect":
        double radius = sqrt(
              pow(points.last.dx - points.first.dx, 2) +
                  pow(points.last.dy - points.first.dy, 2));
        canvas.drawRect(Rect.fromCircle(center: points.first, radius: radius), paint);
        break;
    }
  }
}
