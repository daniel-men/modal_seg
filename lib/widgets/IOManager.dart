import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:modal_seg/Base64Utils.dart';

class IOManager {
  static final IOManager _manager = IOManager._internal();

  List<String> _selectedFiles = [];
  List<Uint8List> _imagesAsBytes = [];
  ui.Image? _selectedImage;
  int? _originalHeight;
  int? _originalWidth;
  String? _ipAdress;
  late Function exportCallback;
  late Function onNewDataCallback;

  factory IOManager({exportCallback, onNewDataCallback}) {
    return _manager;
  }

  IOManager._internal();

  String? get ipAdress => this._ipAdress;
  set ipAdress(String? ipAdress) => this._ipAdress = ipAdress;

  ui.Image? get selectedImage => this._selectedImage;

  set imagesAsBytes(List<Uint8List> imagesAsBytes) =>
      this._imagesAsBytes = imagesAsBytes;

  set selectedFiles(List<String> selectedFiles) =>
      this._selectedFiles = selectedFiles;
  List<String> get selectedFiles => this._selectedFiles;

  Future<void> loadImage(String filename) async {
    Uint8List imageBytes;
    if (_imagesAsBytes.isNotEmpty) {
      imageBytes = _imagesAsBytes[_selectedFiles.indexOf(filename)];
    } else {
      imageBytes = await File(filename).readAsBytes();
    }

    ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    ui.Image _image = (await codec.getNextFrame()).image;

    _originalHeight = _image.height;
    _originalWidth = _image.width;

    _selectedImage = _image;
  }

  bool isFollowingImage(String image, String followingImage) =>
      _selectedFiles.indexOf(image) ==
      _selectedFiles.indexOf(followingImage) - 1;

  Future<Map<dynamic, dynamic>?> checkForNewData() async {
    if (ipAdress != null) {
      String url = 'https://$ipAdress:5000/server';
      try {
        http.Response response = await http.get(Uri.parse(url));
        var decodedResponse = jsonDecode(response.body);
        return decodedResponse;
      } catch (e) {
        //print(e.toString());
        return Map();
      }
    }
  }

  void sendToServer(dynamic json) {
    if (_ipAdress != null) {
      String url = 'https://$ipAdress:5000/server';
      http.post(Uri.parse(url),
          headers: {'content-type': 'application/json'}, body: json);
    }
  }

  Future<void> loadNewDataAsync(List<String> filenames,
      [Iterable? encodedBytes]) async {    

    _selectedFiles = filenames;
    if (encodedBytes != null) {
      List<Uint8List> bytes = encodedBytes.map((v) => Uint8List.fromList(
                                  Base64Util.base64Decoder(v)))
                              .toList()
                              .cast<Uint8List>();
      _imagesAsBytes = bytes;
      onNewDataCallback();
    }    
  }

  bool checkIfFilesAreSame(List<String> newFiles) => 
  newFiles.isEmpty ? false : listEquals(_selectedFiles, newFiles);


}
