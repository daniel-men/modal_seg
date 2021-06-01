import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:modal_seg/ShapeManager.dart';

// ignore: must_be_immutable
class ClassCreationWidget extends StatefulWidget {
  late double strokeWidth;
  final ShapeManager shapeManager;
  late String? className;
  late String? originalClassname;
  Color? color;

  ClassCreationWidget({required this.shapeManager, String? className, Color? color}) {
    this.className = className != null ? className : "";
    this.originalClassname = className;
    this.color = color != null ? color : Color(0xff443a49);
    this.strokeWidth = shapeManager.getStrokeWidth(this.className!);
  }

  @override
  State<StatefulWidget> createState() => ClassCreationWidgetState();
  
}

class  ClassCreationWidgetState extends State<ClassCreationWidget> {
  TextEditingController textController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    if (widget.className != "") {
      textController.text = widget.className!;
    }
    return SingleChildScrollView(
              child: Column(children: [
            Card(
                child: TextField(
              textAlign: TextAlign.center,
              controller: textController,
              onChanged: (value) {
                widget.className = value;
              },
              decoration: InputDecoration(hintText: "Enter class name"),
            )),
            Card(
              child: ColorPicker(
                pickerColor: widget.color!,
                onColorChanged: (c) {
                  widget.color = c;
                },
                colorPickerWidth: 300.0,
                pickerAreaHeightPercent: 0.7,
                enableAlpha: true,
                displayThumbColor: true,
                showLabel: true,
                paletteType: PaletteType.hsv,
                pickerAreaBorderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(2.0),
                  topRight: const Radius.circular(2.0),
                ),
              ),
            ),
           Card(
            child: Column(children: [
          Text("Stroke width: ${widget.strokeWidth.round()}.0"),
          Slider(
              min: 1.0,
              max: 25.0,
              value: widget.strokeWidth,
              onChanged: (value) {
                setState(() {
                  widget.strokeWidth = value;
                  String name = widget.originalClassname != null ? widget.originalClassname! : widget.className!;
                  widget.shapeManager.setClassStrokeWidth(value, name);
                });
                //widget.onStrokeWidthChanged(value);
              })
        ])),
            Card(
                child: Center(
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (widget.originalClassname == null) {
                              widget.shapeManager.addClass(widget.className!, widget.color!);
                            } else {
                              widget.shapeManager.changeClassname(widget.className!, widget.originalClassname!);
                              widget.shapeManager.setClassColor(widget.className!, widget.color!);
                              widget.shapeManager.setClassStrokeWidth(widget.strokeWidth, widget.className!);
                            }
                            
                          });
                          Navigator.pop(context);
                        },
                        child: Text("Save"))))
          ]));
  }
  
}