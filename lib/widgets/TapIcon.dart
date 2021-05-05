import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TapIcon extends StatelessWidget {
  final Function()? onTap;
  final IconData? icon;
  final bool isActive;

  const TapIcon({Key? key, required this.onTap, required this.icon, required this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
              onTap: onTap,
              child: Container(
                height: 60,
                width: 60,
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.black,
                ),
              ),
            );
  }

  
}