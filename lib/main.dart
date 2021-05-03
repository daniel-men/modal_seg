
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/IO.dart';
import 'dart:ui' as ui;
import 'package:modal_seg/widgets/DataImporter.dart';

import 'package:modal_seg/widgets/DropDownAppBar.dart';
import 'package:modal_seg/widgets/SideBar.dart';
import 'package:modal_seg/widgets/ToolMenu.dart';
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
  List<Offset> drawingPoints = <Offset>[];
  String drawingMode = "Line";
  List<String> selectedFiles = [];
  ui.Image? selectedImage;
  Offset? currentPosition;
  Map<String?, List<Shape>> fileToShapeMap = {};
  String? _cursorPosition;
  String? _currentlyOpenedImage = "";
  String? ipAdress;
  List<Uint8List> imagesAsBytes = [];

  // Drawing options
  bool _panEnabled = true;
  bool _zoomEnabled = false;
  bool _drawingEnabled = false;
  int? _value;
  bool? _closeShape = false;

  // Image properties needed for translation
  int? _originalHeight;
  int? _originalWidth;

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
                    elements: selectedFiles,
                    onTap: changeSelectedImage,
                    fileToShapeMap: fileToShapeMap,
                    currentlyOpened: _currentlyOpenedImage))),
        Viewer(
            _panEnabled,
            _zoomEnabled,
            _drawingEnabled,
            _closeShape!,
            _updateCursorPosition,
            _onNewShape,
            drawingMode,
            selectedImage,
            fileToShapeMap[_currentlyOpenedImage])
      ]),
      floatingActionButton: buildFAB(),
    );
  }

  Widget buildFAB() {
    return Stack(children: [
      Align(
    alignment: Alignment.bottomRight,
    child: FloatingActionButton(
      backgroundColor: Colors.red,
      child: Icon(Icons.refresh),
      tooltip: 'Clear Screen',
      onPressed: () {
        setState(() {
          drawingPoints.clear();
          //shapes.clear();
          fileToShapeMap.remove(_currentlyOpenedImage);
        });
      },
    )),
    Align(
    alignment: Alignment.bottomCenter,
    child: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.close),
        onPressed: () {
          setState(() {
            fileToShapeMap[_currentlyOpenedImage] = [];
          });
        }))]);
  }

  void _updateCursorPosition(PointerHoverEvent event) {
    int x = event.localPosition.dx.toInt();
    int y = event.localPosition.dy.toInt();

    setState(() {
      _cursorPosition = "X: $x, Y: $y";
    });
  }

  void _onNewShape(Shape shape) {
    setState(() {
      //shapes = List.from(shapes)..add(shape);
      if (fileToShapeMap.containsKey(_currentlyOpenedImage)) {
        List<Shape> shapes = fileToShapeMap[_currentlyOpenedImage]!;
        bool found = false;
        for (Shape s in shapes) {
          if (shape.timestamp == s.timestamp) {
            int index = fileToShapeMap[_currentlyOpenedImage]!.indexOf(s);
            fileToShapeMap[_currentlyOpenedImage]![index] = shape;
            found = true;
          }
        }
        if (!found) {
          fileToShapeMap[_currentlyOpenedImage]!.add(shape);
        }
      } else {
      fileToShapeMap[_currentlyOpenedImage] = [shape];
      }
    });
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

    _originalHeight = _image.height;
    _originalWidth = _image.width;

    setState(() {
      selectedImage = _image;
    });
  }

  Future<void> changeSelectedImage(String filename) async {

    // Set new image
    setState(() {
      if (_currentlyOpenedImage != null) {
        if (selectedFiles.indexOf(_currentlyOpenedImage!) == selectedFiles.indexOf(filename) - 1 && fileToShapeMap.containsKey(_currentlyOpenedImage!)) {
          fileToShapeMap[filename] = fileToShapeMap[_currentlyOpenedImage]!;
        }
      }
      _currentlyOpenedImage = filename;

    });
    loadImage(filename);

  }

  PreferredSizeWidget buildAppBar() {
    Widget cursorContainer;
    if (_cursorPosition != null && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
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
    if (_currentlyOpenedImage != null) {
      currentlyOpenedImageName = Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(_currentlyOpenedImage!.split("\\").last));
    } else {
      currentlyOpenedImageName = Container();
    }

    return DropDownAppBar(
        child: Row(children: [
      Spacer(),
      /*
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
          )),*/
      ToolMenu(onChanged: (value) {
        setState(() {
          drawingMode = value;
        });
      }),
      /*
      ElevatedButton(
        child: Text("Save to file"),
        onPressed: () {
          String url =
              "C:\\Users\\d.mensing\\Documents\\Projekte\\Cure-OP\\Daten\\segmentations.json";
          writeShapesToFile(url, getShapeJson());
        },
      ),

       */
      Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() {
                _panEnabled = true;
                _zoomEnabled = false;
                _drawingEnabled = false;
                _value = 0;
              }),
              child: Container(
                height: 60,
                width: 60,
                child: Icon(
                  Icons.pan_tool,
                  color: _value == 0 ? Colors.white : Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _panEnabled = false;
                _zoomEnabled = true;
                _drawingEnabled = false;
                _value = 1;
              }),
              child: Container(
                height: 60,
                width: 60,
                child: Icon(
                  Icons.zoom_in,
                  color: _value == 1 ? Colors.white : Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _panEnabled = false;
                _zoomEnabled = false;
                _drawingEnabled = true;
                _value = 2;
              }),
              child: Container(
                height: 50,
                width: 60,
                child: Icon(
                  Icons.edit,
                  color: _value == 2 ? Colors.white : Colors.black,
                ),
              ),
            ),
            Container(
              child: Row(
                children: [
                  Text("Close shape"),
                  Checkbox(
                      value: _closeShape,
                      onChanged: (value) => setState(() => _closeShape = value == null ? false : value))
                ],
              ),
            )
          ],
        ),
      ),
      currentlyOpenedImageName,
      ElevatedButton(
        child: Text("Send to server"),
        onPressed: () async {
          String shapeJson = await getShapeJson();
          DataImporter.sendToServer(ipAdress, shapeJson);
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
            fileToShapeMap.clear();
            imagesAsBytes = bytes;
          });
        },
        currentFiles: selectedFiles,
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

  Future<String> getShapeJson() async {
    Map<String?, String> jsonMap = {};
    for (MapEntry<String?, List<Shape>> mapEntry in fileToShapeMap.entries) {
      
      /*
      List<List<dynamic>?> points = await snapToBlack(
          selectedImage!,
          mapEntry.value
              .getPointsInShape(_originalHeight, _originalWidth, 256, 256));
      */
      List<dynamic> points = [];
      for (Shape shape in mapEntry.value) {
        List<List<dynamic>> shapePoints = tupleToList(shape.getPointsInShape(_originalHeight, _originalWidth, 256, 256));
        points.add(shapePoints);
      }
      //List<List<dynamic>> points = tupleToList(mapEntry.value.getPointsInShape(_originalHeight, _originalWidth, 256, 256));
      jsonMap[mapEntry.key] = jsonEncode(points);
    }

    return jsonEncode(jsonMap);
  }
}
