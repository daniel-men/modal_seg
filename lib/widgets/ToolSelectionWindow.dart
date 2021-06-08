import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/DrawingManager.dart';
import 'package:modal_seg/widgets/DrawingToolMenuEntry.dart';

// ignore: must_be_immutable
class ToolSelectionWindow extends StatefulWidget {
  /*
  final Function(bool?) onShapeClosed;
  final Function(double?) onStrokeWidthChanged;
  final Function(bool?) onStraightLineChanged;
  final Function(String) onDrawingModeChanged;
  */
  final DrawingManager drawingManager;

  bool? closeShape;
  double? strokeWidth;
  bool? straightLine;

  ToolSelectionWindow({
    required this.drawingManager,
    /*
      required this.onShapeClosed,
      required this.closeShape,
      required this.onStrokeWidthChanged,
      required this.strokeWidth,
      required this.straightLine,
      required this.onStraightLineChanged,
      required this.onDrawingModeChanged
      */
  }) {
    closeShape = drawingManager.closeShape;
    strokeWidth = drawingManager.strokeWidth;
    straightLine = drawingManager.straightLine;
  }

  @override
  State<StatefulWidget> createState() => ToolSelectionWindowState();
}

class ToolSelectionWindowState extends State<ToolSelectionWindow> {
  tabChanged(int tab) {
    switch (tab) {
      case 0:
        widget.drawingManager.drawingMode = "Line";
        break;
      case 1:
        widget.drawingManager.drawingMode = "Polyline";
        break;
      case 2:
        widget.drawingManager.drawingMode = "Circle";
        break;
      case 3:
        widget.drawingManager.drawingMode = "Rect";
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    int initialIndex;
    switch (widget.drawingManager.drawingMode) {
      case "Line":
        initialIndex = 0;
        break;
      case "Polyline":
        initialIndex = 1;
        break;
      case "Circle":
        initialIndex = 2;
        break;
      case "Rect":
        initialIndex = 3;
        break;
      default:
        initialIndex = 0;
    }

    return DefaultTabController(
        length: 4,
        initialIndex: initialIndex,
        child: Scaffold(
          appBar: TabBar(
            onTap: tabChanged,
            unselectedLabelColor: Colors.lightBlue,
            labelColor: Colors.blue,
            tabs: [
              Tab(icon: Icon(Icons.edit_outlined)),
              Tab(icon: Icon(Icons.linear_scale_outlined)),
              Tab(icon: Icon(Icons.lens_outlined)),
              Tab(icon: Icon(Icons.check_box_outline_blank))
            ],
          ),
          body: TabBarView(
            children: [
              Container(
                  child: Column(children: [
                Card(
                  child: CheckboxListTile(
                      value: widget.closeShape,
                      title: Text("Close shape"),
                      onChanged: (value) {
                        setState(() {
                          widget.closeShape = value;
                        });
                        widget.drawingManager.closeShape = value;
                      }),
                ),
                Card(
                  child: CheckboxListTile(
                      value: widget.drawingManager.straightLine,
                      title: Text("Straight line"),
                      onChanged: (value) {
                        setState(() {
                          widget.straightLine = value;
                        });
                        widget.drawingManager.straightLine = value;
                      }),
                )
              ])),
              Container(child: Column(children: [
                Card(
                  child: CheckboxListTile(
                      value: widget.closeShape,
                      title: Text("Close shape"),
                      onChanged: (value) {
                        setState(() {
                          widget.closeShape = value;
                        });
                        widget.drawingManager.closeShape = value;
                      }),
                ),
                Card(
                  child: CheckboxListTile(
                      value: widget.drawingManager.straightLine,
                      title: Text("Straight line"),
                      onChanged: (value) {
                        setState(() {
                          widget.straightLine = value;
                        });
                        widget.drawingManager.straightLine = value;
                      }),
                )
              ])),
              Container(),
              Container()
            ],
          ),
        ));
  }
}
