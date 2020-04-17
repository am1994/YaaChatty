import 'dart:io';

import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/components/rounded_button.dart';



class WelcomeScreen extends StatefulWidget {
  static String id= 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}


class _WelcomeScreenState extends State<WelcomeScreen>  with SingleTickerProviderStateMixin{

  AnimationController controller;
  Animation animation;
  bool logged = false;


  @override
  void initState(){
    super.initState();

    controller = AnimationController(duration:  Duration(seconds: 2), vsync: this,);
    animation= ColorTween(begin: Colors.blueGrey,end: Colors.white).animate(controller);
    controller.forward();

    controller.addListener((){
      setState(() {
        print(controller.value);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  //Handle button Back pressed
  Future<bool> alert(){
    return showDialog(context: context,builder:
        (context) => AlertDialog(
          title: Text("Are you sure ?"),
          content: new Text('Do you want to exit ya Chatty App'),
          actions: <Widget>[
        new GestureDetector(
          onTap: () => Navigator.of(context).pop(false),
          child: Text("NO"),
        ),
        SizedBox(height: 16),
        new GestureDetector(
          onTap: () => exit(0),
          child: Text("YES"),
        ),
      ],
    ),
    ) ??
        false;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
       onWillPop: () => alert(),
      child: Scaffold(
        backgroundColor: animation.value,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image.asset('images/chat_logo.png'),
                      height: 60.0,
                    ),
                  ),
                  TypewriterAnimatedTextKit(
                    text:['Ya Chatty'],
                    textStyle: TextStyle(
                      color: Colors.black87,
                      fontSize: 45.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 48.0,
              ),
             RoundedButton(color: Color(0xff72CAAF),
                 onPressed: (){
                   Navigator.pushNamed(context, LoginScreen.id);

                 },buttonText: 'Log In'),
              RoundedButton(color: Colors.black,
                onPressed: (){
                Navigator.pushNamed(context, RegistrationScreen.id);
                }
                ,buttonText: 'Register',)
        ],
      ),)),
    );
  }
}


