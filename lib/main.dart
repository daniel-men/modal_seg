import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/DrawingManager.dart';
import 'package:modal_seg/ShapeManager.dart';
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
  String? ipAdress;

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
      appBar: SegmentationAppBar(drawingManager: drawingManager, ioManager: ioManager, currentImage: shapeManager.currentImage, cursorPosition: _cursorPosition),
      body: Row(children: [
        Expanded(
            flex: 1,
            child: Container(
                padding: EdgeInsets.all(4.0),
                child: SideBar(
                    //elements: selectedFiles,
                    elements: ioManager.selectedFiles,
                    onTap: changeSelectedImage,
                    shapeManager: shapeManager))),
        Viewer(          
            _updateCursorPosition,
            _onNewShape,
            ioManager.selectedImage,
            shapeManager,
            drawingManager
            )
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

  /*
  Future<void> loadImage(String filename) async {
    Uint8List imageBytes;
    if (imagesAsBytes.isNotEmpty) {
      imageBytes = imagesAsBytes[selectedFiles.indexOf(filename)];
    } else {
      imageBytes = await File(filename).readAsBytes();
    }

    ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    ui.Image _image = (await codec.getNextFrame()).image;

    _originalHeight = _image.height;
    _originalWidth = _image.width;

    setState(() {
      selectedImage = _image;
    });
  }
  */

  Future<void> changeSelectedImage(String filename) async {
    // Set new image
    setState(() {
      if (shapeManager.currentImage != "") {
        if (
          ioManager.isFollowingImage(shapeManager.currentImage, filename) &&
            shapeManager.contains(shapeManager.currentImage)
          ) {
          shapeManager.propagateShapes(_currentlyOpenedImage!, filename);
        }
      }
      shapeManager.currentImage = filename;
    });
    ioManager.loadImage(filename);
  }

  /*
  PreferredSizeWidget buildAppBar() {
    Widget cursorContainer;
    if (_cursorPosition != null &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      cursorContainer = Container(
          margin: EdgeInsets.all(10),
          child: Text(_cursorPosition!,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)));
    } else {
      cursorContainer = Container();
    }

    Widget currentlyOpenedImageName;
    if (shapeManager.currentImage != "") {
      currentlyOpenedImageName = Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(shapeManager.currentImage.split("\\").last));
    } else {
      currentlyOpenedImageName = Container();
    }

    return CustomAppBar(
        child: Row(children: [
      Spacer(),
      
      ElevatedButton(
          onPressed: () => openToolMenu(context),
          child: Text("Open Tool menu")),
      
      Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            TapIcon(
              onTap: () => setState(() {
                drawingManager.enablePanMode();
              }),
              icon: Icons.pan_tool,
              isActive: drawingManager.currentInteractionMode() == 0              
            ),
            TapIcon(
              onTap: () => setState(() {                
                drawingManager.enableZoomMode();
              }),
              icon: Icons.zoom_in,
              isActive: drawingManager.currentInteractionMode() == 1              
            ),
            TapIcon(
              onTap: () => setState(() {
                drawingManager.enableDrawMode();
              }),
              icon: Icons.edit,
              isActive: drawingManager.currentInteractionMode() == 2) 
          ],
        ),
      ),
      currentlyOpenedImageName,
      ElevatedButton(
        child: Text("Send to server"),
        onPressed: () async {
          String shapeJson = await shapeManager.toJson();
          //DataImporter.sendToServer(ipAdress, shapeJson);
        },
      ),
      ElevatedButton(
        child: Text("Set IP"),
        onPressed: () {
          showIPDialog(context);
        },
      ),
      DataImporter(
        ioManager: ioManager,
        /*
        onNewDataCallback: (List<String> toBeAnnotated, List<Uint8List> bytes) {
          setState(() {
            /*
            selectedFiles = toBeAnnotated;
            shapeManager.clear();
            imagesAsBytes = bytes;
            */
            ioManager.selectedFiles = toBeAnnotated;
            ioManager.imagesAsBytes = bytes;
            shapeManager.clear();
          });
        },
        */
        //currentFiles: ioManager.selectedFiles,
      ),
      cursorContainer,
      Spacer()
    ]));
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
                      ipAdress = valueText;
                      Navigator.pop(context);
                    });
                  },
                  child: Text("OK", style: TextStyle(color: Colors.white)))
            ],
          );
        });
  }

  Future<void> openToolMenu(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Tool Menu"),
            content: ToolSelectionWindow(
                closeShape: drawingManager.closeShape,
                onShapeClosed: (value) => drawingManager.closeShape = value,
                strokeWidth: drawingManager.strokeWidth,
                onStrokeWidthChanged: (value) => drawingManager.strokeWidth = value,
                straightLine: drawingManager.straightLine,
                onStraightLineChanged: (value) => drawingManager.straightLine = value,
                onDrawingModeChanged: (value) => drawingManager.drawingMode = value),
          );
        });
  }
  */

 
}
