import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/shapes/Shape.dart';
import 'package:modal_seg/widgets/FileCardListView.dart';

class SideBar extends StatefulWidget {
  List<String> elements;
  final Function onTap;
  final Map<String, Shape> fileToShapeMap;
  final String currentlyOpened;


  SideBar({this.onTap, List<String> elements, this.fileToShapeMap, this.currentlyOpened}) {
    this.elements = elements;
  }

  @override
  State<StatefulWidget> createState() => SideBarState();

}

class SideBarState extends State<SideBar> {
  @override
  Widget build(BuildContext context) {
    if (widget.elements.isEmpty) {
      return Container(
          color: Colors.amber[100],
          height: double.infinity,
          child: Center(child: Text("No opened files")));
    } else {
      return Container(
          color: Colors.amber[100],
          child: ListView(
            children: widget.elements
                .map((f) {
                    Color c = Colors.amber[200];
                    if (widget.fileToShapeMap.containsKey(f)) {
                      c = Colors.green;
                    } else if (f == widget.currentlyOpened) {
                      c = Colors.yellow;
                    }
                    return FileCardListView(onTap: widget.onTap, file: f, color: c);})
                .toList(),
          ));
    }
  }
  
}