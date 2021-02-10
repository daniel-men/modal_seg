import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropDownAppBar extends PreferredSize {
  final Widget child;
  final double height;

  DropDownAppBar({@required this.child, this.height = kToolbarHeight});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      color: Colors.orange,
      alignment: Alignment.center,
      child: child,
    );
  }
}