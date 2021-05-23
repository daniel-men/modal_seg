import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/DrawingManager.dart';
import 'package:modal_seg/widgets/CustomAppBar.dart';
import 'package:modal_seg/widgets/DataImporter.dart';
import 'package:modal_seg/IOManager.dart';
import 'package:modal_seg/widgets/TapIcon.dart';
import 'package:modal_seg/widgets/ToolSelectionWindow.dart';

class SegmentationAppBar extends StatefulWidget with PreferredSizeWidget {
  final DrawingManager drawingManager;
  final IOManager ioManager;
  final String currentImage;
  final double height;
  final String? cursorPosition;

  const SegmentationAppBar(
      {Key? key,
      required this.drawingManager,
      required this.ioManager,
      required this.currentImage,
      this.height = kToolbarHeight,
      required this.cursorPosition})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SegmentationAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class SegmentationAppBarState extends State<SegmentationAppBar> {
  @override
  PreferredSizeWidget build(BuildContext context) {
    return CustomAppBar(
        height: widget.height,
        child: //Column(children: [
          Row(children: [
            Spacer(),
            ElevatedButton(
                onPressed: () => openToolMenu(context),
                child: Text("Drawing Tools")),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  TapIcon(
                      onTap: () => setState(() {
                            widget.drawingManager.enablePanMode();
                          }),
                      icon: Icons.pan_tool,
                      isActive:
                          widget.drawingManager.currentInteractionMode() == 0),
                  TapIcon(
                      onTap: () => setState(() {
                            widget.drawingManager.enableZoomMode();
                          }),
                      icon: Icons.zoom_in,
                      isActive:
                          widget.drawingManager.currentInteractionMode() == 1),
                  TapIcon(
                      onTap: () => setState(() {
                            widget.drawingManager.enableDrawMode();
                          }),
                      icon: Icons.edit,
                      isActive:
                          widget.drawingManager.currentInteractionMode() == 2),
                ],
              ),
            ),
            createImageNameContainer(),
            createCursorContainer(),
            ElevatedButton(
              child: Text("Send to server"),
              onPressed: () async {
                widget.ioManager.exportCallback();
              },
            ),
            ElevatedButton(
              child: Text("Set IP"),
              onPressed: () {
                showIPDialog(context);
              },
            ),
            DataImporter(ioManager: widget.ioManager),
            Spacer()
          //])
        ]));
  }

  Widget createImageNameContainer() {
    Widget currentlyOpenedImageName;
    if (widget.currentImage != "") {
      currentlyOpenedImageName = Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(widget.currentImage.split("\\").last));
    } else {
      currentlyOpenedImageName = Container();
    }
    return currentlyOpenedImageName;
  }

  Widget createCursorContainer() {
    Widget cursorContainer;
    if (widget.cursorPosition != null &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      cursorContainer = Container(
          margin: EdgeInsets.all(10),
          child: Text(widget.cursorPosition!,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)));
    } else {
      cursorContainer = Container();
    }
    return cursorContainer;
  }

  Future<void> openToolMenu(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Tool Menu"),
            content: ToolSelectionWindow(
                closeShape: widget.drawingManager.closeShape,
                onShapeClosed: (value) =>
                    widget.drawingManager.closeShape = value,
                strokeWidth: widget.drawingManager.strokeWidth,
                onStrokeWidthChanged: (value) =>
                    widget.drawingManager.strokeWidth = value,
                straightLine: widget.drawingManager.straightLine,
                onStraightLineChanged: (value) =>
                    widget.drawingManager.straightLine = value,
                onDrawingModeChanged: (value) =>
                    widget.drawingManager.drawingMode = value),
          );
        });
  }

  Future<void> showIPDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          String? valueText;
          return AlertDialog(
            title: Text('IP Address of Server'),
            content: TextField(
              onChanged: (value) {
                valueText = value;
              },
              decoration: InputDecoration(hintText: "Enter valid IP adress"),
            ),
            actions: [
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green)),
                  onPressed: () {
                    setState(() {
                      widget.ioManager.ipAdress = valueText;
                      Navigator.pop(context);
                    });
                  },
                  child: Text("OK", style: TextStyle(color: Colors.white)))
            ],
          );
        });
  }
}
