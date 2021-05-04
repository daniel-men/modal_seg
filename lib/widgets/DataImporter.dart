import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/Base64Utils.dart';

import 'package:http/http.dart' as http;

class DataImporter extends StatelessWidget {
  final Function? onNewDataCallback;
  final String? ipAdress;
  final List<String>? currentFiles;

  DataImporter(
      {Key? key, this.onNewDataCallback, this.ipAdress, this.currentFiles})
      : super(key: key);

  Future<void> loadNewDataAsync(List<String> filenames,
      [List<Uint8List>? bytes]) async {
    List<String> toBeAnnotated = [];
    for (var fileName in filenames) {
      toBeAnnotated.add(fileName);
    }

    onNewDataCallback!(toBeAnnotated, bytes);
  }

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 10)).asyncMap(
            (i) => checkForNewData()), // i is null here (check periodic docs)
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<String> filenames = [];
          if (snapshot.hasData) {
            filenames = List<String>.from(snapshot.data.keys);
          }
          if (snapshot.hasData &&
              !snapshot.data.isEmpty &&
              !listEquals(filenames, currentFiles)) {
            return Container(
                color: Colors.green[400],
                margin: EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green[900])),
                    onPressed: () {
                      loadNewDataAsync(
                          filenames,
                          snapshot.data.values
                              .map((v) => Uint8List.fromList(
                                  Base64Util.base64Decoder(v)))
                              .toList()
                              .cast<Uint8List>());
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

  static void sendToServer(String? ipAddress, dynamic json) {
    if (ipAddress != null) {
      String url = 'https://$ipAddress:5000/server';
      http.post(Uri.parse(url),
          headers: {'content-type': 'application/json'}, body: json);
    }
  }
}
