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
          //alignment: Alignment.bottomRight,
          right: MediaQuery.of(context).size.width * .19,
          bottom:  MediaQuery.of(context).size.height * 0.01,
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            child: Icon(Icons.refresh),
            tooltip: 'Clear Screen',
            /*
            onPressed: () {
              setState(() {
                drawingPoints.clear();
                shapeManager.deleteAllShapesForCurrentImage();
              });
            },
            */
            onPressed: onClearPressed,
          )),
      Positioned(
          left: MediaQuery.of(context).size.width * .215,
          bottom:  MediaQuery.of(context).size.height * 0.01,
          //alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: Icon(Icons.close),
              /*
              onPressed: () {                
                setState(() {
                  shapeManager.setNoShapesForCurrentImage();
                });
              }
              */
              onPressed: onEmptyPressed,
              ))
    ]);
  }
  
}