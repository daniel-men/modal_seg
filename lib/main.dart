import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/DrawingManager.dart';
import 'package:modal_seg/ShapeManager.dart';
import 'package:modal_seg/widgets/ClassSelectionSidebar.dart';
import 'package:modal_seg/widgets/FABS.dart';
import 'package:modal_seg/widgets/IOManager.dart';
import 'package:modal_seg/widgets/SegmentationAppBar.dart';
import 'package:modal_seg/widgets/SideBar.dart';
import 'package:modal_seg/widgets/Viewer.dart';
import 'shapes/Shape.dart';
import 'package:modal_seg/MyHttpOverrides.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _cursorPosition;
  String? _currentlyOpenedImage = "";

  _MyHomePageState() {
    ioManager.exportCallback = exportShapesToServer;
  }

  ShapeManager shapeManager = ShapeManager();
  DrawingManager drawingManager = DrawingManager();
  IOManager ioManager = IOManager();

  exportShapesToServer() async {
    String json = await shapeManager.toJson();
    ioManager.sendToServer(json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: buildAppBar(),
      appBar: SegmentationAppBar(
          drawingManager: drawingManager,
          ioManager: ioManager,
          currentImage: shapeManager.currentImage,
          cursorPosition: _cursorPosition),
      body: Row(children: [
        Expanded(
            flex: 1,
            child: Container(
                padding: EdgeInsets.all(4.0),
                child: SideBar(
                    elements: ioManager.selectedFiles,
                    onTap: changeSelectedImage,
                    shapeManager: shapeManager))),
        Viewer(_updateCursorPosition, _onNewShape, ioManager.selectedImage,
            shapeManager, drawingManager),
        Expanded(
            flex: 1,
            child: Container(
                padding: EdgeInsets.all(4.0),
                child: ClassSelectionSidebar(       
                    shapeManager: shapeManager)))
      ]),
      floatingActionButton: FABS(
        onClearPressed: () => setState(() {
          shapeManager.deleteAllShapesForCurrentImage();
        }),
        onEmptyPressed: () => setState(() {
          shapeManager.setNoShapesForCurrentImage();
        }),
      ),
    );
  }

  void _updateCursorPosition(PointerHoverEvent event) {
    int x = event.localPosition.dx.toInt();
    int y = event.localPosition.dy.toInt();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setState(() {
        _cursorPosition = "X: $x, Y: $y";
      });
    }
  }

  void _onNewShape(Shape shape) {
    setState(() {
      shape.strokeWidth = drawingManager.strokeWidth;
      shapeManager.addShape(shape);
    });
  }

  Future<void> changeSelectedImage(String filename) async {
    // Set new image
    setState(() {
      if (shapeManager.currentImage != "") {
        if (ioManager.isFollowingImage(shapeManager.currentImage, filename) &&
            shapeManager.contains(shapeManager.currentImage)) {
          shapeManager.propagateShapes(_currentlyOpenedImage!, filename);
        }
      }
      shapeManager.currentImage = filename;
    });
    ioManager.loadImage(filename);
  }
}
