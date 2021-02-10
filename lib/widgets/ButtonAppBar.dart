import 'package:flutter/material.dart';

class ButtonAppBar extends StatefulWidget {
  final Function onChanged;

  const ButtonAppBar({Key key, this.onChanged}) : super(key: key);


  

  @override
  State<StatefulWidget> createState() => ButtonAppBarState();
  
}

class ButtonAppBarState extends State<ButtonAppBar> {
  String dropDownValue = "Line";

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double height = (mediaQuery.size.height - mediaQuery.padding.top)*0.1;
    return Container(
      padding: EdgeInsets.all(10),
      height: height,
      child: Row(
        children: [
          DropdownButton(
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
          ])
        ],
      ));
  }
}