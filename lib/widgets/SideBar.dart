import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/ShapeManager.dart';
import 'package:modal_seg/widgets/FileCardListView.dart';

class SideBar extends StatefulWidget {
  final List<String>? elements;
  final Function? onTap;
  final ShapeManager shapeManager;



  SideBar({
    this.onTap,
     this.elements,
      required this.shapeManager});

  @override
  State<StatefulWidget> createState() => SideBarState();

}

class SideBarState extends State<SideBar> {

  @override
  Widget build(BuildContext context) {
    if (widget.elements!.isEmpty) {
      return Container(
          color: Colors.amber[100],
          height: double.infinity,
          child: Center(child: Text("No opened files")));
    } else {
      return Container(
          color: Colors.amber[100],
          child: ListView(
            children: widget.elements!
                .map((f) {
                    Color? c = Colors.amber[200];
                    if(widget.shapeManager.contains(f)) {
                      c = Colors.green;
                    } else if (f == widget.shapeManager.currentImage) {
                      c = Colors.yellow;
                    }
                    return FileCardListView(onTap: widget.onTap, file: f, color: c);})
                .toList(),
          ));
    }
  }
  
}