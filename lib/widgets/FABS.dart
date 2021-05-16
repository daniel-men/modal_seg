import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FABS extends StatelessWidget {

  final Function()? onClearPressed;
  final Function()? onEmptyPressed;

  const FABS({Key? key, required this.onClearPressed, required this.onEmptyPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          right: MediaQuery.of(context).size.width * .19,
          bottom:  MediaQuery.of(context).size.height * 0.01,
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            child: Icon(Icons.refresh),
            tooltip: 'Clear Screen',           
            onPressed: onClearPressed,
          )),
      Positioned(
          left: MediaQuery.of(context).size.width * .215,
          bottom:  MediaQuery.of(context).size.height * 0.01,
          child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: Icon(Icons.close),
              tooltip: 'No segmentation in image',
              onPressed: onEmptyPressed,
              ))
    ]);
  }
  
}