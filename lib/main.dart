import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:modal_seg/Base64Utils.dart';


import 'package:modal_seg/widgets/DropDownAppBar.dart';
import 'package:modal_seg/widgets/FileCardListView.dart';
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
                padding: EdgeInsets.all(4.0), child: populateSideBar())),
        Expanded(
            flex: 3,
            child: MouseRegion(
                onHover: _updateCursorPosition,
                child: InteractiveViewer(
                    panEnabled: true,
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

    ui.Codec codec =
        await ui.instantiateImageCodec(imageBytes);
    ui.Image _image = (await codec.getNextFrame()).image;

    setState(() {
      selectedImage = _image;
    });
  }

  Widget populateSideBar() {
    if (selectedFiles.isEmpty) {
      return Container(
          color: Colors.amber[100],
          height: double.infinity,
          child: Center(child: Text("No opened files")));
    } else {
      return Container(
          color: Colors.amber[100],
          child: ListView(
            children: selectedFiles
                .map((f) => FileCardListView(onTap: changeSelectedImage, file: f))
                .toList(),
          ));
    }
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

  Widget buildStreamBuilder() {
    return StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 10)).asyncMap(
            (i) => checkForNewData()), // i is null here (check periodic docs)
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.data.isEmpty) {
            return Container(
                color: Colors.green[400],
                margin: EdgeInsets.all(8.0),
                child: RaisedButton(
                    color: Colors.green[900],
                    onPressed: () {
                      List<String> filenames = List<String>.from(snapshot.data.keys);
                      loadNewDataAsync(filenames, snapshot.data.values.map((v) => Uint8List.fromList(Base64Util.base64Decoder(v))).toList().cast<Uint8List>());
                    },
                    child: Text(
                      "Import new data",
                      style: TextStyle(color: Colors.white),
                    )));
          } else {
            return Container(
                color: Colors.red,
                margin: EdgeInsets.all(8.0),
                child: Text(
                  "No new data found",
                  style: TextStyle(color: Colors.white),
                ));
          }
        }); // builder should also handle the case when data is not fetched yet
  }

  Future<Map<dynamic, dynamic>> checkForNewData() async {
    //String url =  'http://127.0.0.1:5000/server';
    String url = 'http://$ipAdress:5000/server';
    try {
      http.Response response = await http.get(url);
      var decodedResponse = jsonDecode(response.body);
      return decodedResponse;
    } catch (SocketException) {
      print(e.toString());
      return Map();
    }
  }

  Future<void> loadNewDataAsync(List<String> filenames, [List<Uint8List> bytes]) async {
    List<String> toBeAnnotated = [];
    String filePath =
        "C:\\Users\\d.mensing\\Documents\\Projekte\\Cure-OP\\Daten\\cropped\\unlabelled_frames\\";
    for (var fileName in filenames) {
      toBeAnnotated.add(filePath + fileName);
    }

  

    setState(() {
      selectedFiles = toBeAnnotated;
      if (bytes != null) {
        imagesAsBytes = bytes;
      }
    });
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
          String url = "C:\\Users\\d.mensing\\Documents\\Projekte\\Cure-OP\\Daten\\segmentations.json";
          writeShapesToFile(url);
        },
      ),
      ElevatedButton(
        child: Text("Send to server"),
        onPressed: () {
          String url = 'http://$ipAdress:5000/server';
          http.post(url,
              headers: {'content-type': 'application/json'},
              body: getShapeJson());
        },
      ),
      ElevatedButton(
        child: Text("Set IP"),
        onPressed: () {
          showIPDialog(context);
        },
      ),
      buildStreamBuilder(),
      cursorContainer
    ]));
  }

  Future<void> showIPDialog(BuildContext context) async {
    return showDialog(context: context,
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
            }, child: Text("OK"))
          ],
        );
      }
    );
  }

  Future<void> writeShapesToFile(String filename) async {
  File file = File(filename);
  file.writeAsString(jsonEncode(getShapeJson()), mode: FileMode.write);
}

String getShapeJson() {
    Map<String, String> jsonMap = fileToShapeMap.map((key, value) => MapEntry(key, jsonEncode(value.getPointsInShape())));
    return jsonEncode(jsonMap);
}

}


