import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flash_chat/screens/profile_screen.dart';
import 'package:flash_chat/screens/setting_screen.dart';
import 'package:flash_chat/components/avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final  _firestore = Firestore.instance;
FirebaseUser loggedInUser;
final _auth=FirebaseAuth.instance;

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();


  bool showSpinner = false;
  @override
  void initState() {
    super.initState();
    getCurrentUser();  }

  void getCurrentUser() async{
    try{
      final user = await _auth.currentUser();
      if(user != null){
        loggedInUser = user;
        print(loggedInUser.email);
      }}catch(e){
      print(e);
    }
  }

  void deleteUserUid() async {

    final SharedPreferences prefs = await _prefs;
    prefs.setString("user_id", '');


  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                   gradient: RadialGradient(
                   colors: [ Colors.white,logoColor],
                     stops: [0.3, 1],
                   ),
                  color: kMyMessageBubble,
//                  image:  const DecorationImage(
//                    image: AssetImage('images/images.jpeg'),
//                    fit: BoxFit.cover,
//                  ),
                ),

                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                      );
                    }
                    final List<DocumentSnapshot> infos = snapshot.data.documents;
                    int i = 0;
                    var nickname ='';
                    var photoUrl = '';

                    while(  i  <  infos.length){
                      if(infos[i]['id'] == loggedInUser.uid){
                      nickname = infos[i]['nickname'];
                      photoUrl = infos[i]['pic_url'];
                      }
                      i++;
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                     photoUrl != ''
                       ? Material(
                        child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                              backgroundColor: kbackProgressColor,
                             strokeWidth: 2.0,
                             valueColor: AlwaysStoppedAnimation<Color>(kValueProgressColor),),
                        width: 90.0,
                        height: 90.0,
                        padding: EdgeInsets.all(20.0),),
                        imageUrl: photoUrl,
                        width: 90.0,
                        height: 90.0,
                         fit: BoxFit.cover,
                      ),
                       borderRadius: BorderRadius.all(Radius.circular(45.0)),
                       clipBehavior: Clip.hardEdge,
                    ) : Avatar(40.0,Colors.white,Colors.lightBlueAccent),
                        Text(toFirstLetterToUpperCase(nickname),style: TextStyle(
                          fontSize: 24.0,color: Colors.black,
                          fontWeight: FontWeight.bold,),),
                      ],

                    );
                  }
                )

            ),
            ListTile(
              leading: Icon(Icons.person,color: Colors.black,),
              title: Text('Profil',style: TextStyle(fontWeight: FontWeight.bold),),
              onTap: () async{
                Navigator.push(context, MaterialPageRoute(builder: (context)
                =>  ProfileScreen(loggedInUser.uid)));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings,color: Colors.black,),
              title: Text('Setting',style: TextStyle(fontWeight: FontWeight.bold),),
              onTap: () async{
                Navigator.push(context, MaterialPageRoute(builder: (context)
                => Setting()));
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_back,color: Colors.black,),
              title: Text('Sign out',style: TextStyle(fontWeight: FontWeight.bold),),
              onTap: () async {
                deleteUserUid();
                await _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

