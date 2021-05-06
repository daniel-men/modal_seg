import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:modal_seg/ShapeManager.dart';

class ClassSelectionSidebar extends StatefulWidget {
  final ShapeManager shapeManager;

  const ClassSelectionSidebar({Key? key, required this.shapeManager})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ClassSelectionSidebarState();
}

class ClassSelectionSidebarState extends State<ClassSelectionSidebar> {
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.shapeManager.classes.isEmpty) {
      child = Expanded(
          child: SizedBox(
              child: Column(children: [
        Spacer(),
        Center(child: Text("No classes")),
        Spacer()
      ])));
    } else {
      child =
          Container(height: 500, child: ListView(children: createClassTiles()));
    }

    return Container(
        color: Colors.amber[100],
        height: double.infinity,
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                    child: Text("Add new class"),
                    onPressed: showColorPickerDialog)),
            child
          ],
        ));
  }

  List<Widget> createClassTiles() {
    return widget.shapeManager.classes.entries
        .map((e) => Card(
            color: Colors.white,
            child: ListTile(
              title: Text(e.key),
              leading: GestureDetector(
                  onTap: () => showColorPickerDialog(e.key, e.value),
                  child: Icon(Icons.circle, color: e.value)),
              trailing: GestureDetector(
                  onTap: () async {
                    bool shouldDelete = false;
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                                "Are you sure you want to delete the class ${e.key}?"),
                            actions: [
                              TextButton(
                                  child: Text('Yes'),
                                  onPressed: () {
                                    shouldDelete = true;
                                    Navigator.of(context).pop();
                                  }),
                              TextButton(
                                  child: Text('No'),
                                  onPressed: () {
                                    shouldDelete = false;
                                    Navigator.of(context).pop();
                                  })
                            ],
                          );
                        });
                    if (shouldDelete) {
                      setState(() {
                      widget.shapeManager.removeClass(e.key);
                    });
                    }
                    
                  },
                  child: Icon(Icons.delete)),
            )))
        .toList();
  }

  showColorPickerDialog([String? className, Color? color]) {
    TextEditingController textController = TextEditingController();
    Color initialColor = Color(0xff443a49);
    String? originalClassname = className;
    String? newClassname = className;
    Color? newColor = color == null ? initialColor : color;
    if (className != null && color != null) {
      textController.text = className;
      initialColor = color;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          content: SingleChildScrollView(
              child: Column(children: [
            Card(
                child: TextField(
              textAlign: TextAlign.center,
              controller: textController,
              onChanged: (value) {
                newClassname = value;
              },
              decoration: InputDecoration(hintText: "Enter class name"),
            )),
            Card(
              child: ColorPicker(
                pickerColor: initialColor,
                onColorChanged: (c) {
                  newColor = c;
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
                child: Center(
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (originalClassname == null &&
                                newClassname != null) {
                              // new class
                              widget.shapeManager
                                  .addClass(newClassname!, newColor!);
                            }
                            if (originalClassname != null &&
                                newClassname != null) {
                              // class name update
                              widget.shapeManager.changeClassname(
                                  newClassname!, originalClassname);
                              widget.shapeManager.setClassColor(newClassname!,
                                  newColor!); // in case color changed
                            }
                          });
                          Navigator.pop(context);
                        },
                        child: Text("Save"))))
          ])),
        );
      },
    );
  }
}
