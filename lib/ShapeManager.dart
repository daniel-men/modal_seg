import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modal_seg/IO.dart';
import 'package:modal_seg/shapes/Shape.dart';

class ShapeManager {
  static final ShapeManager _shapeManager = ShapeManager._internal();
  Map<String, List<Shape>> _fileToShapeMap = {};
  String _currentlyOpenedImage = "";
  Map<String, Color> _classes ={};
  String _activeClass = "";
  late num _originalHeight;
  late num _originalWidth;
  late num _scaledHeight;
  late num _scaledWidth;

  Map<String, Color> get classes => this._classes;

  String get currentImage => this._currentlyOpenedImage;
  set currentImage(String imageName) => this._currentlyOpenedImage = imageName;

  void setActiveClass(String key) => _activeClass = key;
  String get activeClass => _classes.containsKey(_activeClass) ? _activeClass : "";

  Color getClassColor(String classname) => classname == "" ? Colors.blue : _classes[classname]!;

  factory ShapeManager({num originalHeight = 1000, num originalWidth = 1000, num scaledHeight = 256, num scaledWidth = 256}) {
    _shapeManager._originalHeight = originalHeight;
    _shapeManager._originalWidth = originalWidth;
    _shapeManager._scaledHeight = scaledHeight;
    _shapeManager._scaledWidth = scaledWidth;
    return _shapeManager;
  }

  ShapeManager._internal();

  void removeClass(String className) => this._classes.remove(className);

  void addClass(String newClass, Color color) {
    this._classes[newClass] = color;
    this._activeClass = newClass;
  }

  void changeClassname(String newClassname, String oldClassname) {
    _classes[newClassname] = _classes[oldClassname]!;
    _classes.remove(oldClassname);
  }

  void setClassColor(String className, Color color) => _classes[className] = color;

  Color getActiveColor() => _activeClass != "" ? _classes[_activeClass]! : Colors.blue;

  void addShape(Shape shape) {
    if (_fileToShapeMap.containsKey(_currentlyOpenedImage)) {
      List<Shape> shapes = _fileToShapeMap[_currentlyOpenedImage]!;
      bool found = false;
      for (Shape s in shapes) {
        if (shape.timestamp == s.timestamp) {
          int index = _fileToShapeMap[_currentlyOpenedImage]!.indexOf(s);
          _fileToShapeMap[_currentlyOpenedImage]![index] = shape;
          found = true;
        }
      }
      if (!found) {
        _fileToShapeMap[_currentlyOpenedImage]!.add(shape);
      }
    } else {
      _fileToShapeMap[_currentlyOpenedImage] = [shape];
    }
  }

  void deleteShape(Shape shape) {
    if (_fileToShapeMap.containsKey(_currentlyOpenedImage)) {
      int index = shape.index;
      List<Shape> shapes = _fileToShapeMap[_currentlyOpenedImage]!;
      if (shapes.length == 1) {
        _fileToShapeMap.remove(_currentlyOpenedImage);
      } else {
        if (index == shapes.length - 1) {
          shapes.removeAt(index);
         
        }
        else {
          for (Shape s in shapes) {
            if (s.index > index) {
              s.index -= 1;
            }
          }
          shapes.removeAt(index);          
        }      
        _fileToShapeMap[_currentlyOpenedImage] = shapes;
      }
    }
  }

  setCurrentImage(String imageName) => _currentlyOpenedImage = imageName;

  int getNextIndex() {
    int index = 0;
    if(_fileToShapeMap.containsKey(_currentlyOpenedImage)) {
      index = _fileToShapeMap[_currentlyOpenedImage]!.length;
    }
    return index;
  }

  List<Shape> getCurrentShapes() {
    if (_fileToShapeMap.containsKey(_currentlyOpenedImage)) {
      return _fileToShapeMap[_currentlyOpenedImage]!;
    } else {
      return [];
    }
  }

  void clear() => _fileToShapeMap.clear();

  void deleteAllShapesForCurrentImage() => _fileToShapeMap.remove(_currentlyOpenedImage);
  
  void setNoShapesForCurrentImage() => _fileToShapeMap[_currentlyOpenedImage] = [];

  List<List<dynamic>> getShapePoints(Shape shape) {
    return tupleToList(shape.getPointsInShape(_originalHeight, _originalWidth, _scaledHeight, _scaledWidth));
  }

  String shapesToJson(List<Shape> shapes) {
    List<dynamic> points = [];
    for (Shape shape in shapes) {
      points.add(getShapePoints(shape));
    }
    return jsonEncode(points);
  }

  Future<String> toJson() async {
    Map<String, String> jsonMap = {};
    for (MapEntry<String, List<Shape>> entry in _fileToShapeMap.entries) {
      jsonMap[entry.key] = shapesToJson(entry.value);
    }
    return jsonEncode(jsonMap);
  }

  bool contains(String key) => _fileToShapeMap.containsKey(key);

  void propagateShapes(String source, String target) =>
    _fileToShapeMap[target] = _fileToShapeMap[_currentlyOpenedImage]!.map((shape) => shape.copy()).toList();



}
