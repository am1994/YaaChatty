import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'chat_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


final  _firestore = Firestore.instance;

class LoginScreen extends StatefulWidget {
  static String id= 'login_screen';


  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth=FirebaseAuth.instance;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final loginTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  String nickname;

  bool showSpinner = false;
  String email;
  String password;

  void saveUserId(String uid) async{
    final SharedPreferences prefs = await _prefs;
     prefs.setString("user_id", uid);
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBodyColor,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        color: Colors.black,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/chat_logo.png'),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                   controller: loginTextController,
                onChanged: (value) {
                  //Do something with the user input.
                       email = value;
                },
                decoration: kInputTextFieldDecoration.copyWith(
                  hintText: "Enter you email",
              )
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  controller: passwordTextController,
                onChanged: (value) {
                  //Do something with the user input.
                      password=value;
                },
                decoration:kInputTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                )
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(color: Color(0xff72CAAF),
                  onPressed: () async{

                    setState(() {
                      showSpinner = true;
                    });
                    /*log in  user*/
                      await _auth.signInWithEmailAndPassword(
                          email: email, password: password).then((onValue){
                        setState(() {
                          showSpinner = false;
                        });
                          if(onValue.user.isEmailVerified) {
                            saveUserId(onValue.user.uid);
                            passwordTextController.clear();
                            loginTextController.clear();
                            Navigator.pushNamed(context, ChatScreen.id);
                          }else{
                            Fluttertoast.showToast(msg: "please verify your mail");
                          }
                        }).catchError((onError){
                        setState(() {
                          showSpinner = false;
                        });
                        if(onError.toString().contains("ERROR_EMAIL_ALREADY_IN_USE")){
                          Fluttertoast.showToast(msg: "The email address is already in use by another account");
                        } else
                        if(onError.toString().contains("ERROR_NETWORK_REQUEST_FAILED")){
                          Fluttertoast.showToast(msg: "check out your network");
                        }else if(onError.toString().contains("ERROR_INVALID_EMAIL")){
                          Fluttertoast.showToast(msg: "The email address is badly formatted");
                        }else if(onError.toString().contains("ERROR_WRONG_PASSWORD")){
                          Fluttertoast.showToast(msg: "The password is invalid");
                        }else{
                          Fluttertoast.showToast(msg: onError.toString());
                        }
                      });


                      }
                  ,buttonText: 'Log In'),

            ],
          ),
        ),
      ),
    );
  }
}


