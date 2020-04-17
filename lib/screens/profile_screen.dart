import 'package:flash_chat/module/bottom_left_clipper.dart';
import 'package:flash_chat/module/clip_shadow.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flash_chat/components/avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/widgets.dart';

final  _firestore = Firestore.instance;

final _auth=FirebaseAuth.instance;
FirebaseUser loggedInUser;
//I have changed (avatar - profile image)
class ProfileScreen extends StatefulWidget {
final userUid;
ProfileScreen(this.userUid);


  @override
  _ProfileScreenState createState() => _ProfileScreenState(userUid);
}

class _ProfileScreenState extends State<ProfileScreen> {
  final usrUid;
  _ProfileScreenState(this.usrUid);
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

  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    final double topPhoto= size.height * 0.2;
    final double topInfo = topPhoto * 0.2;

    return Scaffold(
      backgroundColor: kBackgroundBodyColor,
      appBar: AppBar(
             title: Align(
                 alignment: Alignment.center,
                 child: Text("Profile",)),
           ),
      body:  SafeArea(
                    child: StreamBuilder<QuerySnapshot>(
                       stream: _firestore.collection('users').snapshots(),
                       builder: (context, snapshot) {
                         if (!snapshot.hasData) {
                           return Center(
                             child: CircularProgressIndicator(
                               backgroundColor: logoColor,
                             ),
                           );
                         }
                         final List<DocumentSnapshot> infos = snapshot.data
                             .documents;
                         int i = 0;
                         var nickname = '';
                         var photoUrl = '';
                         var age = '';
                         var about = '';

                         while (i < infos.length) {
                           if (infos[i]['id'] == usrUid) {
                             nickname = infos[i]['nickname'];
                             photoUrl = infos[i]['pic_url'];
                             age = infos[i]['age'];
                             about = infos[i]['about'];
                           }
                           i++;
                         }
                         return Column(
                           children: <Widget>[
                             Stack(
                             alignment: Alignment.center,
                              overflow: Overflow.visible,
                             children: <Widget>[
                               ShaderMask(
                                 shaderCallback: (Rect bounds) =>
                                     RadialGradient(
                                       center: Alignment.topCenter,
                                       radius: 2.0,
                                       colors: <Color>[ logoColor,Colors.white],
                                       tileMode: TileMode.mirror,
                                     ).createShader(bounds),
                                 child: ClipShadowPath(
                                     shadow: BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(-5,3),
                                                blurRadius: 5,
                                               spreadRadius: 10,
                                                    ),
                                            clipper: BottomLeftNeuClipper(),
                                          child: Image.asset(
                                                        'images/back_image_profil.jpg'),
//                                             ,
//                                            child: Container(
//                                              height: size.height * 0.3,
//                                             color : logoColor,
                                              ),
                                                 ),
                               //),

//                               Container(
//                                 padding: EdgeInsets.only(bottom: 30.0),
//                                child: Card(
//                                   elevation: 20.0,
//                                     child: Image.asset(
//                                         'images/back_image_profil.jpg')),
//                               ),
                               Positioned(
                                 top: topPhoto,
                                 child: photoUrl != ''
                                     ? Material(
                                   child: CachedNetworkImage(
                                     placeholder: (context, url) =>
                                         Container(
                                           child: CircularProgressIndicator(
                                             backgroundColor: kbackProgressColor,
                                             strokeWidth: 2.0,
                                             valueColor: AlwaysStoppedAnimation<
                                                 Color>(kValueProgressColor),),
                                           width: 90.0,
                                           height: 90.0,
                                           padding: EdgeInsets.all(20.0),),
                                     imageUrl: photoUrl,
                                     width: 150.0,
                                     height: 150.0,
                                     fit: BoxFit.cover,
                                   ),
                                   borderRadius: BorderRadius.all(Radius
                                       .circular(70.0)),
                                   clipBehavior: Clip.hardEdge,
                                 ) : Avatar(40.0, Colors.lightBlueAccent,
                                     Colors.white),
                               ),
                             ],


                           ),
                             Container(
                               margin: EdgeInsets.only(top: size.height * 0.1),
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.center,

                                 children: <Widget>[
                                   InfoCard(text:toFirstLetterToUpperCase(nickname),size: 24,),
                                   InfoCard(text: age,size:25),
                                   InfoCard(text: about,size: 16)
                                 ],
                               ),
                             ),




                           ],
                         );
                       }),
    )


    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final double size;

  const InfoCard({Key key, this.text,this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return text =='' ? Container() :
    ShaderMask(
        shaderCallback: (Rect bounds) =>
        RadialGradient(
          center: Alignment.topLeft,
          radius: 2.0,
          colors: <Color>[Colors.white, logoColor],
          tileMode: TileMode.mirror,
        ).createShader(bounds),

      child:   Column(
        children:<Widget>[
          Container(
          alignment:null,
           height: 70,
             width: 300,
          child: Card(
         color: kPartnerMessageBubble,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(20.0),
           ),
          elevation: 10.0,
          child: Align(
              alignment: Alignment.center,
              child: Text(text,textAlign:TextAlign.center,style:TextStyle(color:Colors.blueGrey,
                  fontSize: size,
                  fontWeight: FontWeight.bold),)),),
          ),
            SizedBox(
          height: 8.0,
    ),

  ]  )

    );
  }
}
