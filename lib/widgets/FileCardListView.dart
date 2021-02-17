
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
          if (_color.value != Colors.green.value) {
            _color = Colors.amber[800];
          }
        })
      },
      onExit: (PointerExitEvent pe) => {
        setState(() {
          if (_color.value != Colors.green.value) {
            _color = Colors.amber[200];
          }
          
        })
      },
        child: Card(
            child: ListTile(
                trailing: _trailing,
                title: Text(widget.file.split("\\").last),
                tileColor: _color,
                selectedTileColor: Colors.amber,
                onTap: () {
                  setState(() {
                    if (_color.value == Colors.green.value) {
                      _color = Colors.amber;
                    }
                    else {_color = Colors.green;}
                  });
                  widget.onTap(widget.file);
                  })));
  }


}
