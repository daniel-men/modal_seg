import 'dart:convert';
import 'dart:io';

import 'package:tuple/tuple.dart';

Future<void> writeShapesToFile(String filename, Object toJSON) async {
    File file = File(filename);
    file.writeAsString(jsonEncode(toJSON), mode: FileMode.write);
  }

List<List<dynamic>> tupleToList(Set<Tuple2<int, int>> tupleList) {
  return tupleList.map((e) => e.toList()).toList();
}