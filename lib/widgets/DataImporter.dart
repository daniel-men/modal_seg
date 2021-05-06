import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_seg/widgets/IOManager.dart';

class DataImporter extends StatelessWidget {
  final IOManager ioManager;

  DataImporter({Key? key, required this.ioManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 10)).asyncMap((i) => ioManager
            .checkForNewData()), // i is null here (check periodic docs)
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<String> filenames =
              snapshot.hasData ? List<String>.from(snapshot.data.keys) : [];
          if (snapshot.hasData &&
              !snapshot.data.isEmpty &&
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
                          filenames, snapshot.data.values);
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
