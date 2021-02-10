import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToolMenu extends StatefulWidget {
  final Function onChanged;

  const ToolMenu({Key key, this.onChanged}) : super(key: key);


  

  @override
  State<StatefulWidget> createState() => ToolMenuState();
  
}

class ToolMenuState extends State<ToolMenu> {
  String dropDownValue = "Line";

  @override
  Widget build(BuildContext context) {
    
        return Container(
          padding: EdgeInsets.all(10),
          child: DropdownButton(
            value: dropDownValue,
            onChanged: (String newValue) {
              widget.onChanged(newValue);
              setState(() {
                dropDownValue = newValue;
              });              
            },
            items: [
              DropdownMenuItem(value: "Line", child: Row(children: [Text("Line"), Icon(Icons.line_style)])),
              DropdownMenuItem(value: "Circle", child: Row(children: [Text("Circle"), Icon(Icons.circle)])),
              DropdownMenuItem(value: "Rect", child: Row(children: [Text("Rect"), Icon(Icons.check_box_outline_blank)]))
          ]));
      
  }
}