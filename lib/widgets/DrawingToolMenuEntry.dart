import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DrawingToolMenuEntry extends StatefulWidget {
  final List<Widget> children;
  late double strokeWidth;
  final Function onStrokeWidthChanged;

  DrawingToolMenuEntry(
      {required this.children,
      required double strokeWidth,
      required this.onStrokeWidthChanged}) {
    this.strokeWidth = strokeWidth;
  }

  @override
  State<StatefulWidget> createState() => DrawingToolMenuEntryState();
}

class DrawingToolMenuEntryState extends State<DrawingToolMenuEntry> {
  @override
  Widget build(BuildContext context) {
    Widget strokewidthCard = buildStrokeWidthCard();
    List<Widget> widgetList = [strokewidthCard];
    widgetList.addAll(widget.children);
    
    return Container(
        child: Column(
      children: widgetList,
    ));
  }


  Widget buildStrokeWidthCard() {
    return Card(
            child: Column(children: [
          Text("Stroke width: ${widget.strokeWidth.round()}.0"),
          Slider(
              min: 1.0,
              max: 25.0,
              value: widget.strokeWidth,
              onChanged: (value) {
                setState(() {
                  widget.strokeWidth = value;
                });
                widget.onStrokeWidthChanged(value);
              })
        ]));
  }
}
