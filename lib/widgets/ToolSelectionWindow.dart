import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/widgets/DrawingToolMenuEntry.dart';

// ignore: must_be_immutable
class ToolSelectionWindow extends StatefulWidget {
  final Function(bool?) onShapeClosed;
  final Function(double?) onStrokeWidthChanged;
  final Function(bool?) onStraightLineChanged;
  final Function(String) onDrawingModeChanged;
  bool? closeShape;
  double? strokeWidth;
  bool? straightLine;

  ToolSelectionWindow(
      {required this.onShapeClosed,
      required this.closeShape,
      required this.onStrokeWidthChanged,
      required this.strokeWidth,
      required this.straightLine,
      required this.onStraightLineChanged,
      required this.onDrawingModeChanged});

  @override
  State<StatefulWidget> createState() => ToolSelectionWindowState();
}

class ToolSelectionWindowState extends State<ToolSelectionWindow> {
  tabChanged(int tab) {
    switch (tab) {
      case 0:
        widget.onDrawingModeChanged("Line");
        break;
      case 1:
        widget.onDrawingModeChanged("Polyline");
        break;
      case 2:
        widget.onDrawingModeChanged("Polyline");
        break;
      case 3:
        widget.onDrawingModeChanged("Rect");
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return    
        DefaultTabController(
            length: 4,
            initialIndex: 0, //TODO
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
                  DrawingToolMenuEntry(
                    strokeWidth: widget.strokeWidth!,
                    onStrokeWidthChanged: widget.onStrokeWidthChanged,
                    children: [
                      Card(
                        child: CheckboxListTile(
                            value: widget.closeShape,
                            title: Text("Close shape"),
                            onChanged: (value) {
                              setState(() {
                                widget.closeShape = value;
                              });
                              widget.onShapeClosed(value);
                            }),
                      ),
                      Card(
                        child: CheckboxListTile(
                            value: widget.straightLine,
                            title: Text("Straight line"),
                            onChanged: (value) {
                              setState(() {
                                widget.straightLine = value;
                              });
                              widget.onStraightLineChanged(value!);
                            }),
                      )                      
                    ],
                  ),
                  DrawingToolMenuEntry(
                    strokeWidth: widget.strokeWidth!,
                    onStrokeWidthChanged: widget.onStrokeWidthChanged,
                    children: []),                
                  DrawingToolMenuEntry(
                    strokeWidth: widget.strokeWidth!,
                    onStrokeWidthChanged: widget.onStrokeWidthChanged,
                    children: []),
                  DrawingToolMenuEntry(
                    strokeWidth: widget.strokeWidth!,
                    onStrokeWidthChanged: widget.onStrokeWidthChanged,
                    children: []),
                ],
              ),
            ));
  }

  
}
