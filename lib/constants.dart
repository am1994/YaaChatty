import 'package:flutter/material.dart';
final kSendButtonTextStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

final kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.grey, width: 2.0),
  ),
);

const kInputTextFieldDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.black),
  hintStyle: TextStyle(color: Colors.grey),
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
final kbackProgressColor = Colors.white;
final kValueProgressColor = Color(0xff72CAAF);
final kBackgroundBodyColor = Colors.white;
final kPartnerMessageBubble= Colors.white;
final kMyMessageBubble = Color(0xff4FC4CC);
final themeColor = Color(0xfff5a623);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);
final logoColor = Color(0xff72CAAF);
const kSettingTextTheme = TextStyle(fontStyle: FontStyle.italic,
    fontWeight: FontWeight.bold, color:  Colors.black);

const kOnlineTextButtonTheme = TextStyle(fontSize: 15,fontWeight: FontWeight.bold);

String editingTime(String time) => time.substring(11,19);


String toFirstLetterToUpperCase(String text){
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}
