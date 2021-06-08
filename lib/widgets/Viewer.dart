import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:modal_seg/DrawingManager.dart';
//import 'package:modal_seg/ImageProcessing/ImageProcessingProvider.dart';
import 'package:modal_seg/ShapeManager.dart';
import 'package:modal_seg/ShapePainter.dart';
import 'package:modal_seg/shapes/Circle.dart';
import 'package:modal_seg/shapes/Line.dart';
import 'package:modal_seg/shapes/PolyLine.dart';
import 'package:modal_seg/shapes/Rect.dart';
import 'dart:ui' as ui;
import 'dart:io' show Platform;

import 'package:modal_seg/widgets/CustomInteractiveViewer.dart' as custom;

// ignore: must_be_immutable
class Viewer extends StatefulWidget {
  final Function _updateCursorPosition;
  final Function _onNewShape;
  final ShapeManager shapeManager;
  final DrawingManager drawingManager;
  //List<Offset> drawingPoints = [];
  final ui.Image? selectedImage;
  //ImageProcessingProvider? imageProcessingProvider;

  Viewer(this._updateCursorPosition, this._onNewShape, this.selectedImage,
      this.shapeManager, this.drawingManager);

  @override
  State<StatefulWidget> createState() => ViewerState();
}

class ViewerState extends State<Viewer> {
  late final custom.TransformationController controller;

  ViewerState() {
    controller = custom.TransformationController();
    controller.addListener(() {
      updateTransformation(controller.value);
    });
  }

  void updateTransformation(Matrix4 updateMarix) {}

  void convertPointsToShape() {
    //if (widget.drawingPoints.isEmpty) {
    if (widget.drawingManager.drawingPoints.isEmpty) {
      return;
    }

    String activeClass = widget.shapeManager.activeClass;
    switch (widget.drawingManager.drawingMode) {
      case "Circle":
        double radius = sqrt(pow(
                widget.drawingManager.drawingPoints.last.dx -
                    widget.drawingManager.drawingPoints.first.dx,
                2) +
            pow(
                widget.drawingManager.drawingPoints.last.dy -
                    widget.drawingManager.drawingPoints.first.dy,
                2));
        widget._onNewShape(Circle(
            initialPoint: widget.drawingManager.drawingPoints.first,
            radius: radius,
            className: activeClass,
            color: widget.shapeManager.getClassColor(activeClass),
            imageName: widget.shapeManager.currentImage,
            index: widget.shapeManager.getNextIndex(),
            onDelete: (value) => setState(() {
                  widget.shapeManager.deleteShape(value);
                })));
        break;
      case "Line":
        if (widget.drawingManager.closeShape) {
          widget.drawingManager.drawingPoints =
              Line.prunePoints(widget.drawingManager.drawingPoints);
        }
        widget._onNewShape(Line(
            className: activeClass,
            color: widget.shapeManager.getClassColor(activeClass),
            points: List.from(widget.drawingManager.drawingPoints),
            onMoved: widget._onNewShape,
            closePath: widget.drawingManager.closeShape,
            imageName: widget.shapeManager.currentImage,
            index: widget.shapeManager.getNextIndex(),
            onDelete: (value) => setState(() {
                  widget.shapeManager.deleteShape(value);
                })));
        break;
      case "Rect":
        double radius = sqrt(pow(
                widget.drawingManager.drawingPoints.last.dx -
                    widget.drawingManager.drawingPoints.first.dx,
                2) +
            pow(
                widget.drawingManager.drawingPoints.last.dy -
                    widget.drawingManager.drawingPoints.first.dy,
                2));
        widget._onNewShape(Rectangle(
            Rect.fromCircle(
                center: widget.drawingManager.drawingPoints.first,
                radius: radius),
            className: activeClass,
            color: widget.shapeManager.getClassColor(activeClass),
            imageName: widget.shapeManager.currentImage,
            index: widget.shapeManager.getNextIndex(),
            onDelete: (value) => setState(() {
                  widget.shapeManager.deleteShape(value);
                })));
        break;
      case "Polyline":
        PolyLine shape = PolyLine(
            points: List.from(widget.drawingManager.drawingPoints),
            className: activeClass,
            onMoved: widget._onNewShape,
            color: widget.shapeManager.getClassColor(activeClass),
            imageName: widget.shapeManager.currentImage,
            index: widget.shapeManager.getNextIndex(),
            onDelete: (value) => setState(() {
                  widget.shapeManager.deleteShape(value);
                }));
        widget._onNewShape(shape);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? viewer = windowsViewer(context);
    /*
    if (Platform.isWindows) {
      viewer = windowsViewer(context);
    } else if (Platform.isIOS) {
      viewer = iOsViewer();
    }
    */

    return Expanded(
        flex: 3,
        child: MouseRegion(
            onHover: (PointerHoverEvent event) {
              widget._updateCursorPosition(event);
              if (widget.drawingManager.isDrawingModePolyline &&
                  widget.drawingManager.polylineActive) {
                setState(() {
                  widget.drawingManager.tempDrawingPoint = event.localPosition;
                });
              }
            },
            child: viewer));
  }

  void offsetCallback(Offset offset) {
    widget.shapeManager.setOffset(offset);
  }

  Widget windowsViewer(BuildContext context) {
    return GestureDetector(
        onDoubleTap: () {
          if (widget.drawingManager.isDrawingModePolyline &&
              widget.drawingManager.polylineActive) {
            widget.drawingManager.polylineActive = false;
            //widget.drawingManager.removeLastDrawingPoint();
            widget.drawingManager.setTempDrawingPointNull();
            convertPointsToShape();
            widget.drawingManager.clearDrawingPoints();
          }
        },
        onTapUp: (TapUpDetails details) {
          if (widget.drawingManager.drawingEnabled &&
              widget.drawingManager.isDrawingModePolyline) {
            if (!widget.drawingManager.polylineActive) {
              widget.drawingManager.polylineActive = true;
            }

            Offset point = details.localPosition;

            setState(() {
              //widget.drawingManager.drawingPoints = List.from(widget.drawingManager.drawingPoints)..add(point);
              widget.drawingManager.addDrawingPoint(point);
            });
            //convertPointsToShape();
          }
        },
        child: custom.CustomInteractiveViewer(
            drawingEnabled: widget.drawingManager.drawingEnabled,
            panEnabled: widget.drawingManager.panEnabled,
            scaleEnabled: widget.drawingManager.zoomEnabled,
            transformationController: controller,
            minScale: 0.5,
            maxScale: 5.0,
            //constrained: false,
            boundaryMargin: const EdgeInsets.all(15.0),
            onInteractionUpdate: (ScaleUpdateDetails details) {
              if (widget.drawingManager.drawingEnabled &&
                  !widget.drawingManager.isDrawingModePolyline) {
                setState(() {
                  Offset point = details.localFocalPoint;
                  widget.drawingManager.addDrawingPoint(point);
                  /*
                  widget.drawingManager.drawingPoints =
                      List.from(widget.drawingManager.drawingPoints)
                        ..add(point);
                        */
                });
              }
            },
            onInteractionEnd: (ScaleEndDetails details) {
              if (widget.drawingManager.drawingEnabled &&
                  !widget.drawingManager.isDrawingModePolyline) {
                convertPointsToShape();
                setState(() {
                  widget.drawingManager.drawingPoints.clear();
                });
              }
            },
            child: Stack(children: [
              /*
          GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                if (widget.drawingManager.drawingEnabled) {
                  setState(() {
                    Offset point = details.localPosition;
                    widget.drawingManager.drawingPoints = List.from(widget.drawingManager.drawingPoints)
                      ..add(point);
                  });
                }
              },
              onPanEnd: (DragEndDetails details) {
                if (widget.drawingManager.drawingEnabled) {
                  convertPointsToShape();
                  setState(() {
                    widget.drawingManager.drawingPoints.clear();
                  });
                }
              },*/
              //child:
              FractionallySizedBox(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Container(
                      padding: EdgeInsets.all(4.0),
                      color: Color.fromARGB(0, 0, 0, 0),
                      child: CustomPaint(
                          painter: ShapePainter(
                              widget.drawingManager.drawingPoints,
                              widget.drawingManager.drawingMode,
                              widget.selectedImage,
                              widget.shapeManager.getCurrentStrokeWidth(),
                              widget.shapeManager.getActiveColor(),
                              offsetCallback)))
                  //)
                  ),
              FractionallySizedBox(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Container(
                      padding: EdgeInsets.all(4.0),
                      alignment: Alignment.topLeft,
                      child: Stack(
                        //children: shapes
                        children: widget.shapeManager.getCurrentShapes(),
                      )))
            ])));
  }

  Widget iOsViewer() {
    return custom.CustomInteractiveViewer(
        panEnabled: widget.drawingManager.panEnabled,
        scaleEnabled: widget.drawingManager.zoomEnabled,
        drawingEnabled: widget.drawingManager.drawingEnabled,
        minScale: 0.25,
        maxScale: 5.0,
        onInteractionUpdate: (ScaleUpdateDetails details) {
          if (widget.drawingManager.drawingEnabled) {
            setState(() {
              Offset point = details.localFocalPoint;
              widget.drawingManager.drawingPoints =
                  List.from(widget.drawingManager.drawingPoints)..add(point);
            });
          }
        },
        onInteractionEnd: (ScaleEndDetails details) {
          if (widget.drawingManager.drawingEnabled &&
              widget.drawingManager.drawingPoints.isNotEmpty) {
            convertPointsToShape();
            setState(() {
              widget.drawingManager.drawingPoints.clear();
            });
          }
        },
        child: Container(
            child: Stack(
          children: [
            FractionallySizedBox(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Container(
                    //padding: EdgeInsets.all(4.0),
                    color: Color.fromARGB(0, 0, 0, 0),
                    child: CustomPaint(
                      painter: ShapePainter(
                          widget.drawingManager.drawingPoints,
                          widget.drawingManager.drawingMode,
                          widget.selectedImage,
                          widget.drawingManager.strokeWidth,
                          widget.shapeManager.getActiveColor(),
                          offsetCallback),
                    ))),
            FractionallySizedBox(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Container(
                    //padding: EdgeInsets.all(4.0),
                    //alignment: Alignment.topLeft,
                    child: Stack(
                        //children: shapes
                        children: widget.shapeManager.getCurrentShapes())))
          ],
        )));
  }
}
