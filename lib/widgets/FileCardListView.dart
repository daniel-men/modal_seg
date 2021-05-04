


import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FileCardListView extends StatefulWidget {
  final Function? onTap;
  final String? file;
  Color? color;

  FileCardListView({this.onTap, this.file, this.color});

  @override
  State<StatefulWidget> createState() => FileCardListViewState();


  
}

class FileCardListViewState extends State<FileCardListView> {

  Icon? _trailing;


  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent pe) => {
        setState(() {
          if (widget.color!.value == Colors.yellow.value || widget.color!.value == Colors.green.value) {            
          } else {
            widget.color = Colors.amber[800];
          }
        })
      },
      onExit: (PointerExitEvent pe) => {
        setState(() {
          if (widget.color!.value == Colors.yellow.value || widget.color!.value == Colors.green.value) {            
          } else {
            widget.color = Colors.amber[200];
          }
          
        })
      },
        child: Card(
            child: ListTile(
                trailing: _trailing,
                title: Text(widget.file!.split("\\").last),
                tileColor: widget.color,
                selectedTileColor: Colors.amber,
                onTap: () {
                 
                  setState(() {
                    if (widget.color!.value == Colors.green.value) {
                      widget.color = Colors.amber;
                    }
                    else {widget.color = Colors.green;}
                  });
                  
                  widget.onTap!(widget.file);
                  })));
  }


}
