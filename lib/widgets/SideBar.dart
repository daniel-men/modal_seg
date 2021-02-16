import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/widgets/FileCardListView.dart';

class SideBar extends StatefulWidget {
  List<String> elements;
  final Function onTap;


  SideBar({this.onTap, List<String> elements}) {
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
                .map((f) =>
                    FileCardListView(onTap: widget.onTap, file: f))
                .toList(),
          ));
    }
  }
  
}