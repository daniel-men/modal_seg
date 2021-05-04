import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        widget.onDrawingModeChanged("Circle");
        break;
      case 2:
        widget.onDrawingModeChanged("Rect");
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: TabBar(
            onTap: tabChanged,
            unselectedLabelColor: Colors.lightBlue,
            labelColor: Colors.blue,
            tabs: [
              Tab(icon: Icon(Icons.line_style)),
              Tab(icon: Icon(Icons.circle)),
              Tab(icon: Icon(Icons.check_box_outline_blank))
            ],
          ),
          body: TabBarView(
            children: [
              Container(
                  child: Column(
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
                  ),
                  Card(
                      child: Column(children: [
                    Text("Stroke width: ${widget.strokeWidth!.round()}.0"),
                    Slider(
                        min: 1.0,
                        max: 25.0,
                        value: widget.strokeWidth!,
                        onChanged: (value) {
                          setState(() {
                            widget.strokeWidth = value;
                          });
                          widget.onStrokeWidthChanged(value);
                        })
                  ]))
                ],
              )),
              Container(),
              Container()
            ],
          ),
        ));
  }
}
