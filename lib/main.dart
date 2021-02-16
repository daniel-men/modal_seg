import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:modal_seg/IO.dart';
import 'package:modal_seg/widgets/DataImporter.dart';

import 'package:modal_seg/widgets/DropDownAppBar.dart';
import 'package:modal_seg/widgets/SideBar.dart';
import 'package:modal_seg/widgets/ToolMenu.dart';
import 'package:modal_seg/shapes/Line.dart';
import 'package:modal_seg/ShapePainter.dart';

import 'shapes/Circle.dart';
import 'shapes/Shape.dart';
import 'shapes/Rect.dart';

void main() {
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
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Offset> drawingPoints = <Offset>[];
  List<Shape> shapes = <Shape>[];
  String drawingMode = "Line";
  List<String> selectedFiles = [];
  ui.Image selectedImage;
  Offset currentPosition;
  Map<String, Shape> fileToShapeMap = {};
  String _cursorPosition;
  String _currentlyOpenedImage;
  String ipAdress;
  List<Uint8List> imagesAsBytes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Row(children: [
        Expanded(
            flex: 1,
            child: Container(
                padding: EdgeInsets.all(4.0),
                child: SideBar(
                    elements: selectedFiles, onTap: changeSelectedImage))),
        Expanded(
            flex: 3,
            child: MouseRegion(
                onHover: _updateCursorPosition,
                child: InteractiveViewer(
                    panEnabled: true,
                    scaleEnabled: true,
                    child: Stack(children: [
                      GestureDetector(
                          onPanUpdate: (DragUpdateDetails details) {
                            setState(() {
                              Offset point = details.localPosition;
                              drawingPoints = List.from(drawingPoints)
                                ..add(point);
                            });
                          },
                          onPanEnd: (DragEndDetails details) {
                            convertPointsToShape();
                            setState(() {
                              drawingPoints.clear();
                            });
                          },
                          child: FractionallySizedBox(
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: Container(
                                  //padding: EdgeInsets.all(4.0),
                                  color: Color.fromARGB(0, 0, 0, 0),
                                  child: CustomPaint(
                                    painter: ShapePainter(drawingPoints,
                                        drawingMode, selectedImage),
                                  )))),
                      FractionallySizedBox(
                          widthFactor: 1.0,
                          heightFactor: 1.0,
                          child: Container(
                              //padding: EdgeInsets.all(4.0),
                              alignment: Alignment.topLeft,
                              child: Stack(children: shapes)))
                    ])))),
      ]),
      floatingActionButton: buildFAB(),
    );
  }

  FloatingActionButton buildFAB() {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      child: Icon(Icons.refresh),
      tooltip: 'Clear Screen',
      onPressed: () {
        setState(() {
          drawingPoints.clear();
          shapes.clear();
        });
      },
    );
  }

  void _updateCursorPosition(PointerHoverEvent event) {
    int x = event.localPosition.dx.toInt();
    int y = event.localPosition.dy.toInt();

    setState(() {
      _cursorPosition = "X: $x, Y: $y";
    });
  }

  void convertPointsToShape() {
    switch (drawingMode) {
      case "Circle":
        double radius = sqrt(
            pow(drawingPoints.last.dx - drawingPoints.first.dx, 2) +
                pow(drawingPoints.last.dy - drawingPoints.first.dy, 2));
        shapes.add(Circle(initialPoint: drawingPoints.first, radius: radius));
        break;
      case "Line":
        //bool closed = Line.isClosed(drawingPoints);
        drawingPoints = Line.prunePoints(drawingPoints);
        shapes.add(Line(points: List.from(drawingPoints)));
        break;
      case "Rect":
        double radius = sqrt(
            pow(drawingPoints.last.dx - drawingPoints.first.dx, 2) +
                pow(drawingPoints.last.dy - drawingPoints.first.dy, 2));
        shapes.add(Rectangle(
            Rect.fromCircle(center: drawingPoints.first, radius: radius)));
        break;
      default:
    }
  }

  Future<void> loadImage(String filename) async {
    Uint8List imageBytes;
    if (imagesAsBytes.isNotEmpty) {
      imageBytes = imagesAsBytes[selectedFiles.indexOf(filename)];
    } else {
      imageBytes = await File(filename).readAsBytes();
    }

    ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    ui.Image _image = (await codec.getNextFrame()).image;

    setState(() {
      selectedImage = _image;
    });
  }

  Future<void> changeSelectedImage(String filename) async {
    // Save existing shape
    if (shapes.isNotEmpty && _currentlyOpenedImage != null) {
      fileToShapeMap[_currentlyOpenedImage] = shapes.first;
    }

    // Set new image
    setState(() {
      _currentlyOpenedImage = filename;
      shapes = [];
    });
    loadImage(filename);

    // Check if shapes already exist for this image
    if (fileToShapeMap.containsKey(_currentlyOpenedImage)) {
      setState(() {
        shapes = List.from(shapes)..add(fileToShapeMap[_currentlyOpenedImage]);
      });
    }
  }

  

  PreferredSizeWidget buildAppBar() {
    Widget cursorContainer;
    if (_cursorPosition != null) {
      cursorContainer = Container(
          margin: EdgeInsets.all(10),
          child: Text(_cursorPosition,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)));
    } else {
      cursorContainer = Container();
    }

    return DropDownAppBar(
        child: Row(children: [
      Container(
          padding: EdgeInsets.all(10),
          child: ElevatedButton.icon(
            onPressed: () async {
              List<FilePickerCross> chosenFiles =
                  await FilePickerCross.importMultipleFromStorage();
              setState(() {
                selectedFiles = chosenFiles.map((e) => e.path).toList();
              });
            },
            icon: Icon(Icons.folder),
            label: Text("Open files"),
          )),
      ToolMenu(onChanged: (value) {
        setState(() {
          drawingMode = value;
        });
      }),
      ElevatedButton(
        child: Text("Save to file"),
        onPressed: () {
          String url =
              "C:\\Users\\d.mensing\\Documents\\Projekte\\Cure-OP\\Daten\\segmentations.json";
          writeShapesToFile(url, getShapeJson());
        },
      ),
      ElevatedButton(
        child: Text("Send to server"),
        onPressed: () {
          String url = 'http://$ipAdress:5000/server';
          DataImporter.sendToServer(url, getShapeJson());
        },
      ),
      ElevatedButton(
        child: Text("Set IP"),
        onPressed: () {
          showIPDialog(context);
        },
      ),
      DataImporter(
        ipAdress: ipAdress,
        onNewDataCallback: (List<String> toBeAnnotated, List<Uint8List> bytes) {
          setState(() {
            selectedFiles = toBeAnnotated;
            if (bytes != null) {
              imagesAsBytes = bytes;
            }
          });
        },
      ),
      cursorContainer
    ]));
  }

  Future<void> showIPDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          String valueText;
          return AlertDialog(
            title: Text('IP Address of Server'),
            content: TextField(
              onChanged: (value) {
                valueText = value;
              },
              decoration: InputDecoration(hintText: "Enter valid IP adress"),
            ),
            actions: [
              FlatButton(
                  color: Colors.green,
                  onPressed: () {
                    setState(() {
                      ipAdress = valueText;
                      Navigator.pop(context);
                    });
                  },
                  child: Text("OK"))
            ],
          );
        });
  }



  String getShapeJson() {
    Map<String, String> jsonMap = fileToShapeMap.map(
        (key, value) => MapEntry(key, jsonEncode(value.getPointsInShape())));
    return jsonEncode(jsonMap);
  }
}
