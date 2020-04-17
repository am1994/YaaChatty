import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flash_chat/components/drawer.dart';
import 'package:flash_chat/module/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/constants.dart';
import 'package:connectivity/connectivity.dart';


final  _firestore = Firestore.instance;

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {


  TextEditingController controllerAge;
  TextEditingController controllerAboutMe;
  TextEditingController controllerNickName;
  String newAge = '';
  String oldAge='';
  String newAboutMe = '';
  String oldAboutMe='';
  String oldNickname='';
  String NewPhotoUrl = '';
  String oldPhotoUrl='';
  String id='';
   String NewNickname='';
  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeAge = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();
  final FocusNode focusNodeNickName = new FocusNode();

  StreamSubscription _connectionChangeStream;
  bool isOffline = false;


  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }
  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
    getUserInfo();
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }
  Future uploadFile() async {
    String fileName = loggedInUser.uid;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null)  {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) async {
          NewPhotoUrl = downloadUrl;
         await Firestore.instance
              .collection('users')
              .document(loggedInUser.photoUrl)
              .updateData({'pic_url': NewPhotoUrl == ''? oldPhotoUrl: NewPhotoUrl}).whenComplete((){
           setState(() {
             isLoading = false;
           });
         })
              .catchError((err) {
            setState(() {
              isLoading = false;
            });
            //Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      //Fluttertoast.showToast(msg: err.toString());
    });
  }
  getUserInfo( ) async{

    _firestore.collection('users').document(loggedInUser.uid).get().then((
        data) {
      setState(() {
        oldNickname = data.data['nickname'];
        oldAboutMe = data.data['about'];
        oldAge = data.data['age'];
        oldPhotoUrl = data.data['pic_url'];
        print(oldPhotoUrl);
      });
    });

  }
  void handleUpdateData() {
    focusNodeAge.unfocus();
    focusNodeAboutMe.unfocus();
    focusNodeNickName.unfocus();
    setState(() {
      isLoading = true;
    });
       if(isOffline) {
         setState(() {
           isLoading = false;
         });
         Fluttertoast.showToast(msg: "check out your connection");
       }else{

         if ((NewNickname == '') && (newAge == '') && (newAboutMe == '') &&
             (NewPhotoUrl == '')) {
           setState(() {
             isLoading = false;
           });
           Fluttertoast.showToast(msg: 'Nothing has changed');
         } else {
           Firestore.instance
               .collection('users')
               .document(loggedInUser.uid)
               .updateData(
               {
                 'nickname': NewNickname == '' ? oldNickname : NewNickname,
                 'age': newAge == '' ? oldAge : newAge,
                 'about': newAboutMe == '' ? oldAboutMe : newAboutMe,
                 'pic_url': NewPhotoUrl == '' ? oldPhotoUrl : NewPhotoUrl
               }).whenComplete(() {
             setState(() {
               isLoading = false;
             });
             Fluttertoast.showToast(msg: 'Successful Updated');
           }).catchError((err) {
             setState(() {
               isLoading = false;
             });
             print(err.toString());
             Fluttertoast.showToast(msg: err.toString());
           });
         }
       }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBodyColor,
      appBar: AppBar(
          title: Align(alignment: Alignment.center,
            child: Text('Setting'),)
        ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Avatar
                Container(
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        (avatarImageFile == null)
                            ? (NewPhotoUrl != ''
                            ? Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                              width: 90.0,
                              height: 90.0,
                              padding: EdgeInsets.all(20.0),
                            ),
                            imageUrl: NewPhotoUrl,
                            width: 90.0,
                            height: 90.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(45.0)),
                          clipBehavior: Clip.hardEdge,
                        )
                            : Icon(
                          Icons.account_circle,
                          size: 90.0,
                          color:  greyColor,
                        ))
                            : Material(
                          child: Image.file(
                            avatarImageFile,
                            width: 90.0,
                            height: 90.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(45.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: primaryColor.withOpacity(0.5),
                          ),
                          onPressed: getImage,
                          padding: EdgeInsets.all(30.0),
                          splashColor: Colors.transparent,
                          highlightColor:  greyColor,
                          iconSize: 30.0,
                        ),
                      ],
                    ),
                  ),
                  width: double.infinity,
                  margin: EdgeInsets.all(20.0),
                ),

                // Input
                Column(
                  children: <Widget>[

                    // Username
                    Container(
                      child: Text(
                        'Nickname',
                       style: kSettingTextTheme,
                      ),
                      margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: primaryColor),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'New nickname',
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: greyColor),
                          ),
                          controller: controllerNickName,
                          onChanged: (value) {
                            NewNickname= value;
                          },
                          focusNode: focusNodeNickName,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    //newAge
                    Container(
                      child: Text(
                        'Age',
                        style: kSettingTextTheme,
                      ),
                      margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: primaryColor),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'how old are you ?',
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: greyColor),
                          ),
                          controller: controllerAge,
                          onChanged: (value) {
                            newAge = value;
                          },
                          focusNode: focusNodeAge,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    // About me
                    Container(
                      child: Text(
                        'About me',
                        style: kSettingTextTheme,
                      ),
                      margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: primaryColor),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Fun, like travel and play PES...',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: greyColor),
                          ),
                          controller: controllerAboutMe,
                          onChanged: (value) {
                            newAboutMe = value;
                          },
                          focusNode: focusNodeAboutMe,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),

                // Button
                Container(
                  child: RaisedButton(
                    onPressed: handleUpdateData,
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 16.0,fontStyle: FontStyle.italic),
                    ),
                    color: Colors.blueGrey,
                    highlightColor: Color(0xff8d93a0),
                    splashColor: Colors.transparent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                  ),
                  margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
                ),
              ],
            ),
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
          ),

          // Loading
          Positioned(
            child: isLoading
                ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    backgroundColor: kbackProgressColor,
                    valueColor: AlwaysStoppedAnimation<Color>(kValueProgressColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
                : Container(),
          ),
        ],
      ),
    );
  }
}