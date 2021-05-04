import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:modal_seg/DrawingManager.dart';
import 'package:modal_seg/ImageProcessing/ImageProcessingProvider.dart';
import 'package:modal_seg/ShapeManager.dart';
import 'package:modal_seg/ShapePainter.dart';
import 'package:modal_seg/shapes/Circle.dart';
import 'package:modal_seg/shapes/Line.dart';
import 'package:modal_seg/shapes/Rect.dart';
import 'dart:ui' as ui;
import 'dart:io' show Platform;

import 'package:modal_seg/widgets/CustomInteractiveViewer.dart';

// ignore: must_be_immutable
class Viewer extends StatefulWidget {
  /*
  final bool _panEnabled;
  final bool _zoomEnabled;
  final bool _drawingEnabled;
  final bool _closeShape;
  final double _strokeWidth;
  */
  final Function _updateCursorPosition;
  final Function _onNewShape;
  //final String drawingMode;
  final ShapeManager shapeManager;
  final DrawingManager drawingManager;
  List<Offset> drawingPoints = [];
  //final List<Shape>? shape;
  final ui.Image? selectedImage;
  ImageProcessingProvider? imageProcessingProvider;
  //late Map<String?, List<Shape>> fileToShapeMap;
  late String currentImage;
  late Function onDelete;

  Viewer(
    /*
      this._panEnabled,
      this._zoomEnabled,
      this._drawingEnabled,
      this._closeShape,
      this._strokeWidth,
      */
      this._updateCursorPosition,
      this._onNewShape,
      //this.drawingMode,
      this.selectedImage,
      this.shapeManager,
      this.drawingManager,
      //this.shape,
      {
        //required Map<String?, List<Shape>> fileToShapeMap,
        required String currentImage,
        required Function onDelete
      }) {
    //this.fileToShapeMap = fileToShapeMap;
    this.currentImage = currentImage;
    this.onDelete = onDelete;
  }

  @override
  State<StatefulWidget> createState() => ViewerState();
}

class ViewerState extends State<Viewer> {
  //ShapeManager shapeManager = ShapeManager();

  void convertPointsToShape() {
    switch (widget.drawingManager.drawingMode) {
      case "Circle":
        double radius = sqrt(pow(
                widget.drawingPoints.last.dx - widget.drawingPoints.first.dx,
                2) +
            pow(widget.drawingPoints.last.dy - widget.drawingPoints.first.dy,
                2));
        widget._onNewShape(
            Circle(initialPoint: widget.drawingPoints.first, radius: radius));
        break;
      case "Line":
        if (widget.drawingManager.closeShape) {
          widget.drawingPoints = Line.prunePoints(widget.drawingPoints);
        }
        /*
        int index = 0;
        if (widget.fileToShapeMap.containsKey(widget.currentImage)) {
          index =  widget.fileToShapeMap[widget.currentImage]!.length;
        }
        */
        widget._onNewShape(Line(
            points: List.from(widget.drawingPoints),
            onMoved: widget._onNewShape,
            closePath: widget.drawingManager.closeShape,
            imageName: widget.currentImage,
            //index: index,
            index: widget.shapeManager.getNextIndex(),
            onDelete: widget.onDelete
            ));
        break;
      case "Rect":
        double radius = sqrt(pow(
                widget.drawingPoints.last.dx - widget.drawingPoints.first.dx,
                2) +
            pow(widget.drawingPoints.last.dy - widget.drawingPoints.first.dy,
                2));
        widget._onNewShape(Rectangle(Rect.fromCircle(
            center: widget.drawingPoints.first, radius: radius)));
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? viewer;
    if (Platform.isWindows) {
      viewer = windowsViewer(context);
    } else if (Platform.isIOS) {
      viewer = iOsViewer();
    }

    return Expanded(
        flex: 3,
        child: MouseRegion(
            onHover: widget._updateCursorPosition as void Function(
                PointerHoverEvent)?,
            child: viewer));
  }

  Widget windowsViewer(BuildContext context) {

    /*
    List<Shape> shapes = [];
    if (widget.shape != null) {
      shapes = widget.shape!;
    }
    */
    return InteractiveViewer(
        panEnabled: widget.drawingManager.panEnabled,
        scaleEnabled: widget.drawingManager.zoomEnabled,
        minScale: 0.5,
        maxScale: 5.0,
        //constrained: false,
        boundaryMargin: const EdgeInsets.all(15.0),
        onInteractionUpdate: (ScaleUpdateDetails details) {
          if (widget.drawingManager.drawingEnabled) {
            setState(() {
              Offset point = details.localFocalPoint;
              widget.drawingPoints = List.from(widget.drawingPoints)
                ..add(point);
            });
          }
        },
        onInteractionEnd: (ScaleEndDetails details) {
          if (widget.drawingManager.drawingEnabled) {
            convertPointsToShape();
            setState(() {
              widget.drawingPoints.clear();
            });
          }
        },
        child: Stack(children: [
          GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                if (widget.drawingManager.drawingEnabled) {
                  setState(() {
                    Offset point = details.localPosition;
                    widget.drawingPoints = List.from(widget.drawingPoints)
                      ..add(point);
                  });
                }
              },
              onPanEnd: (DragEndDetails details) {
                if (widget.drawingManager.drawingEnabled) {
                  convertPointsToShape();
                  setState(() {
                    widget.drawingPoints.clear();
                  });
                }
              },
              child: FractionallySizedBox(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Container(
                      padding: EdgeInsets.all(4.0),
                      color: Color.fromARGB(0, 0, 0, 0),
                      child: CustomPaint(
                        painter: ShapePainter(widget.drawingPoints,
                            widget.drawingManager.drawingMode, widget.selectedImage, widget.drawingManager.strokeWidth),
                      )))),
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
        ]));
  }

  Widget iOsViewer() {
    /*
    List<Shape> shapes = [];
    if (widget.shape != null) {
      shapes = widget.shape!;
    }
    */
    return CustomInteractiveViewer(
        panEnabled: widget.drawingManager.panEnabled,
        scaleEnabled: widget.drawingManager.zoomEnabled,
        drawingEnabled: widget.drawingManager.drawingEnabled,
        minScale: 0.25,
        maxScale: 5.0,
        //boundaryMargin: const EdgeInsets.all(15.0),
        onInteractionUpdate: (ScaleUpdateDetails details) {
          if (widget.drawingManager.drawingEnabled) {
            setState(() {
              Offset point = details.localFocalPoint;
              widget.drawingPoints = List.from(widget.drawingPoints)
                ..add(point);
            });
          }
        },
        onInteractionEnd: (ScaleEndDetails details) {
          if (widget.drawingManager.drawingEnabled && widget.drawingPoints.isNotEmpty) {
            convertPointsToShape();
            setState(() {
              widget.drawingPoints.clear();
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
                      painter: ShapePainter(widget.drawingPoints,
                          widget.drawingManager.drawingMode, widget.selectedImage, widget.drawingManager.strokeWidth),
                    ))),
            FractionallySizedBox(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Container(
                    //padding: EdgeInsets.all(4.0),
                    //alignment: Alignment.topLeft,
                    child: Stack(
                      //children: shapes
                      children: widget.shapeManager.getCurrentShapes()
                      )))
          ],
        )));
  }
}
