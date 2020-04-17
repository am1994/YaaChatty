import 'package:flutter/material.dart';


class Avatar extends StatelessWidget {
  final double radius;
  final Color _backgroundColor;
  final Color _iconColor;
  Avatar(this.radius,this._backgroundColor,this._iconColor);
  @override
  Widget build(BuildContext context) {
    return  CircleAvatar(
      backgroundColor: _backgroundColor,
      child: Icon(Icons.person,size: radius,color: _iconColor,),
      radius:radius,
    );
  }
}


