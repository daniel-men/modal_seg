import 'dart:typed_data';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class FileCardListView extends StatefulWidget {
  final Function onTap;
  final String file;

  FileCardListView({this.onTap, this.file});

  @override
  State<StatefulWidget> createState() => FileCardListViewState();


  
}

class FileCardListViewState extends State<FileCardListView> {

  Color _color = Colors.amber[200];
  Icon _trailing;


  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent pe) => {
        setState(() {
          _color = Colors.amber[800];
        })
      },
      onExit: (PointerExitEvent pe) => {
        setState(() {
          _color = Colors.amber[200];
        })
      },
        child: Card(
            child: ListTile(
                trailing: _trailing,
                title: Text(widget.file.split("\\").last),
                tileColor: _color,
                selectedTileColor: Colors.amber,
                onTap: () => {widget.onTap(widget.file)})));
  }


}
