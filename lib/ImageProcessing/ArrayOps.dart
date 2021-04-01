
/*
import 'package:modal_seg/ImageProcessing/ImageProcessing.dart';

import 'package:scidart/numdart.dart';

enum PADDING_MODE { zeros, repeat }

Array padVector(Array src) {
  Array a = Array.fromArray(src);
  a.insert(0, a.first);
  a.insert(a.length, a.last);
  return a;
}

Array2d? padArray(Array2d src,
    {PADDING_MODE mode = PADDING_MODE.repeat,
    DIRECTION direction = DIRECTION.both}) {
  Array2d? out;

  if (direction == DIRECTION.both) {
    out = Array2d.fixed(src.row + 2, src.column + 2);
  } else if (direction == DIRECTION.xDirection) {
    //out = Array2d.fixed(src.row + 2, src.column);
    out = Array2d.empty();
  } else if (direction == DIRECTION.yDirection) {
    out = Array2d.fixed(src.row, src.column + 2);
  }

  if (direction == DIRECTION.xDirection || direction == DIRECTION.both) {
    if (mode == PADDING_MODE.repeat) {

      out!.add(src.first);    



      for (var i = 0; i < src.row; i++) {
        out.add(src[i]);
      }
      out.add(src.last);
    }
  }
  if (direction == DIRECTION.yDirection || direction == DIRECTION.both) {
    if (mode == PADDING_MODE.repeat) {
      for (var i = 0; i < src.column; i++) {
        setColumn(out!, padVector(getColumn(src, i)), i);
      }
    }
  }
  return out;
}

Array getColumn(Array2d src, int index) {
  Array out = Array.empty();

  for (var i = 0; i < src.row; i++) {
    out.add(src[i][index]);
  }

  return out;
}

Array2d setColumn(Array2d src, Array column, int index) {
  for (var i = 0; i < src.row; i++) {
    src[i][index] = column[i];
  }
  return src;
}

Array2d transpose(Array2d src) {
  Array2d transposed = Array2d.fixed(src.row, src.column);
  for (var x = 0; x < src.row; x++) {
    for (var y = 0; y < src.column; y++) {
      transposed[y][x] = src[x][y];
    }    
  }
  return transposed;
}

Array2d normalize(Array2d src, num low, num high) {
  List<num?> minMax = minMax2D(src);

  Array2d min = Array2d.fixed(src.row, src.column, initialValue: minMax[0] as double);
  Array2d max = Array2d.fixed(src.row, src.column, initialValue: minMax[1] as double);
  Array2d highArr = Array2d.fixed(src.row, src.column, initialValue: high.toDouble());
  Array2d lowArr = Array2d.fixed(src.row, src.column, initialValue: low.toDouble());

  List<Array> out = (src - min) * ((highArr - lowArr) / (max - min)) + lowArr;
  return out as Array2d;
}

num? min2D(Array2d src) {
  num? newMin;
  for (var i = 1; i < src.length; i++) { 
    num minPrev = min(src[i-1]);
    num minElement = min(src[i]);
    newMin = minElement < minPrev ? minElement : minPrev;
  }
  return newMin;
}

num? max2D(Array2d src) {
  num? newMax;
  for (var i = 1; i < src.length; i++) { 
    num maxPrev = min(src[i-1]);
    num maxElement = min(src[i]);
    newMax = maxElement > maxPrev ? maxElement : maxPrev;
  }
  return newMax;
}

List<num?> minMax2D(Array2d src) {
  num? newMin;
  num? newMax;
  for (var i = 1; i < src.length; i++) {
    num minPrev = min(src[i-1]);
    num minElement = min(src[i]);
    num maxPrev = max(src[i-1]);
    num maxElement = max(src[i]);

    newMin = minElement < minPrev ? minElement : minPrev;
    newMax = maxElement > maxPrev ? maxElement : maxPrev;
  }
  return [newMin, newMax];
}

num min(Array src) {
  return src.reduce((previousValue, element) => element < previousValue ? element : previousValue);
}

num max(Array src) {
  return src.reduce((previousValue, element) => element > previousValue ? element : previousValue);
}

*/