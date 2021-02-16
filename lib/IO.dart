  import 'dart:convert';
import 'dart:io';

Future<void> writeShapesToFile(String filename, Object toJSON) async {
    File file = File(filename);
    file.writeAsString(jsonEncode(toJSON), mode: FileMode.write);
  }