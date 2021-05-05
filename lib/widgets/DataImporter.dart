import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/widgets/IOManager.dart';

class DataImporter extends StatelessWidget {
  //final Function? onNewDataCallback;
  final IOManager ioManager;

  DataImporter(
      {Key? key, required this.ioManager})
      : super(key: key);

  /*
  Future<void> loadNewDataAsync(List<String> filenames,
      [List<Uint8List>? bytes]) async {
    List<String> toBeAnnotated = [];
    for (var fileName in filenames) {
      toBeAnnotated.add(fileName);
    }

    onNewDataCallback!(toBeAnnotated, bytes);
  }
  */

  /*
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
  */

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 10)).asyncMap(
            (i) => ioManager.checkForNewData()), // i is null here (check periodic docs)
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<String> filenames = snapshot.hasData ? List<String>.from(snapshot.data.keys) : [];
          if (snapshot.hasData && !snapshot.data.isEmpty &&
              !ioManager.checkIfFilesAreSame(filenames)) {
          
              
            return Container(
                color: Colors.green[400],
                margin: EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green[900])),
                    onPressed: () {
                      ioManager.loadNewDataAsync(
                          filenames,
                          snapshot.data.values);
                          /*
                              .map((v) => Uint8List.fromList(
                                  Base64Util.base64Decoder(v)))
                              .toList()
                              .cast<Uint8List>());
                              */
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


}
