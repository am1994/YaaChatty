import 'package:flutter/material.dart';

class AvatarOnline extends StatelessWidget {
  final double height;
  final Color _backgroundColor;
  final double width;
  final Color _iconColor;
  AvatarOnline(this.height,this._backgroundColor,this._iconColor, this.width);
  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Colors.blue,
      width: width,
      height: height,
      child: CircleAvatar(
        backgroundColor: _backgroundColor,
        child: Icon(Icons.person,size: 35.0,color: _iconColor,),
        radius:35.0,
      ),
    );
  }
}