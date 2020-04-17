import 'dart:math';
import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'direct_chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/components/avatar.dart';
import 'package:flash_chat/screens/profile_screen.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:flash_chat/components/avatar_online.dart';
FirebaseUser loggedInUser;
final  _firestore = Firestore.instance;
final _auth=FirebaseAuth.instance;

class OnlineScreen extends StatefulWidget {
  static String id = 'online_screen';


  @override
  _OnlineScreenState createState() => _OnlineScreenState();
}

class _OnlineScreenState extends State<OnlineScreen> {

  @override
  void initState() {
    super.initState();
    getCurrentUser();


  }
  void getCurrentUser() async{
    try{
      final user = await _auth.currentUser();
      if(user != null){
        loggedInUser = user;
        // addConnectedUser();
        print(loggedInUser.email);
      }}catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: null,
        title: Align(
                 alignment: Alignment.center,
               child: Text("online")),
         ),

          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[



                  UserStream(),
            ],
            ),
        ),
      );
  }


}

class OnlinePerson extends StatelessWidget {

  OnlinePerson(this.email,this.id,this.nickname,this.photoUrl,this.about);
  final String email;
  final String id;
  final String nickname;
  final String photoUrl;
  final String about;

  @override
  Widget build(BuildContext context) {
    return
      Container(

        child: Stack(
          alignment: Alignment.center,
          children:<Widget>[


          Card(
           color: kPartnerMessageBubble,
           shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            margin: EdgeInsets.only(top: 25.0),
            elevation: 10.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(height: 40.0,),
                        Text(toFirstLetterToUpperCase(nickname),style:
                        TextStyle(fontFamily: 'Libre',fontSize: 25.0,
                            color: Color(0xff97E0BB),
                            fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 8.0,),
                       Text(about,style: TextStyle(fontSize: 15.0,color: Colors.blueGrey,
                            fontWeight: FontWeight.bold)),
                        ],
                      ),

                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children:<Widget>[
                         RaisedButton(
                           elevation: 6.0,
                           textColor: Colors.white,
                           color: logoColor,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(20.0),
                           ),
                              onPressed: (){
                                Navigator.push(context,MaterialPageRoute(builder: (context)
                                => ProfileScreen(id),),);},
                           child: Text('Profile', style: kOnlineTextButtonTheme),
                           ),
                          SizedBox(
                            width: 8.0,
                          ),

                          RaisedButton(
                            elevation: 6.0,
                            textColor: Colors.white,
                            color: logoColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                              onPressed: (){
                                Navigator.push(context,MaterialPageRoute(builder: (context)
                                => DirectChatScreen(nickname,id,photoUrl),),);},
                            child: Text('Chat', style: kOnlineTextButtonTheme,),
                              ),
                        ]
                     ),



//                CircleAvatar(
//                  radius: 10.0,
//                  backgroundColor:  Colors.green,
//                ),
              ],
          ),
        //  ),
        ),

            //photo
            Positioned(
              top:0 ,
              child: photoUrl != ''
                  ? Material(
                elevation: 30.0,
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      backgroundColor: kbackProgressColor,
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(kValueProgressColor),),
                    width: 24.0,
                    height: 90.0,
                    padding: EdgeInsets.all(20.0),),
                  imageUrl: photoUrl,
                  width: 70.0,
                  height: 70.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(45.0)),
                clipBehavior: Clip.antiAlias,
              ) : Avatar(35.0,Colors.blueGrey,logoColor),
            ),

      ]
      ),
    );
  }
}

class UserStream extends StatefulWidget {


  @override
  _UserStreamState createState() => _UserStreamState();
}

class _UserStreamState extends State<UserStream> {
  int page=0;
  Container pages;
  PageController  _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.8
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  int clipState = 1;

  static List _colors = [
    Colors.blueGrey,
    Colors.deepPurple,
    Colors.orangeAccent,
    Colors.grey
  ];
  Color _clipColors =  _colors[0];


  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
     final double imageTop = size.height * 0.1;
     final double infoCardTop = imageTop * 0.8;
      final double imageLeft = size.width * 0.1;
      final double cardLeft = imageLeft * 1.60;


    return  StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder:  (context, snapshot) {
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: kbackProgressColor,
              valueColor: AlwaysStoppedAnimation<Color>(kValueProgressColor),
            ),
          );
        }
        final users = snapshot.data.documents;
        List<OnlinePerson> onlinePerson = [];
        List<Container> onilne=[];

        for(var user in users){
          //check if user ID == current user ID , if no show it
         if (user['id'] != loggedInUser.uid) {
           final nickName = user['nickname'];
           final userID = user['id'];
           final url = user['pic_url'];
           final userEmail = user['email'];
           final about = user['about'];
           final age = user['age'];
            pages =  Container(
             child: Material(
               color: Colors.blueGrey.shade100,

               child: Stack(
                 alignment: Alignment.center,
                 overflow: Overflow.visible,
                   children:<Widget>[
                     ///background
//                   Container(
//                     height: size.height,
//                     width: size.width,
//                   ),


//
//
//
//
//
//
////                CircleAvatar(
////                  radius: 10.0,
////                  backgroundColor:  Colors.green,
////                ),
//                       ],
//                     ),
                       //  ),



                     //photo
                    //Photo
                    ///image
                     Positioned(
                       top: imageTop,
                       child: url != ''
                           ? Material(
                         elevation: 30.0,
                         child: CachedNetworkImage(
                           placeholder: (context, url) => Container(
                             child: CircularProgressIndicator(
                               backgroundColor: kbackProgressColor,
                               strokeWidth: 2.0,
                               valueColor: AlwaysStoppedAnimation<Color>(kValueProgressColor),),
                             width: 24.0,
                             height: 90.0,
                             padding: EdgeInsets.all(20.0),),
                           imageUrl: url,
                           width: size.width * 0.8,
                           height:size.height * 0.6,
                           fit: BoxFit.cover,
                         ),
                         borderRadius: BorderRadius.all(Radius.circular(8.0)),
                         clipBehavior: Clip.antiAlias,
                       ) : AvatarOnline(size.height * 0.6,Colors.blueGrey,logoColor,size.width * 0.8),
                       left: imageLeft,
                     ),
                       ///info Card
                     Positioned(
                          bottom: infoCardTop,
                       //left: cardLeft,
                       child: Container(
                            width: size.width * 0.7,
                            height: size.height * 0.2,
                            child: Card(
                              color: kPartnerMessageBubble,
                              shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(10.0),
                             ),
                              //elevation: 10.0,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
                                child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                 children: <Widget>[
                                   Row(
                                     crossAxisAlignment: CrossAxisAlignment.baseline,
                                     textBaseline: TextBaseline.ideographic,
                                     children: <Widget>[
                                       Text(toFirstLetterToUpperCase(nickName),style:
                                       TextStyle(fontFamily: 'Libre',fontSize: 25.0,
                                           color: Colors.black,
                                           fontWeight: FontWeight.bold)),
                                       Text(',$age',style:
                                       TextStyle(fontFamily: 'Libre',fontSize: 15.0,
                                           color: Colors.black,
                                           fontWeight: FontWeight.bold)),
                                             ],
                                   ),

                                   Text(about,style: TextStyle(fontSize: 15.0,color: Colors.blueGrey,
                                       fontWeight: FontWeight.bold)),

                                   Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                                       children:<Widget>[
                                         Expanded(
                                           flex: 1,
                                           child: FlatButton(
                                             //elevation: 6.0,
                                             textColor: Colors.white,
                                             color: Colors.blueGrey,
                                             shape: RoundedRectangleBorder(
                                               borderRadius: BorderRadius.circular(3.0),
                                             ),
                                             onPressed: (){
                                               Navigator.push(context,MaterialPageRoute(builder: (context)
                                               => ProfileScreen(userID),),);},
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: <Widget>[
                                                  Icon(Icons.send),
                                                  Text('Profile', style: kOnlineTextButtonTheme,)
                                                ],
                                              ),

                                           ),
                                         ),
                                         SizedBox(width: 4.0,),
                                         Expanded(
                                           flex: 1,
                                           child: FlatButton(
                                             //elevation: 6.0,
                                             textColor: Colors.white,
                                             color: logoColor,
                                             shape: RoundedRectangleBorder(
                                               borderRadius: BorderRadius.circular(3.0),
                                             ),
                                             onPressed: (){
                                               Navigator.push(context,MaterialPageRoute(builder: (context)
                                               => DirectChatScreen(nickName,userID,url),),);},
                                             child:
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: <Widget>[
                                                    Icon(Icons.person),
                                                    Text('Chat', style: kOnlineTextButtonTheme,)
                                                  ],
                                                ),


                                           ),
                                         ),
                                       ]
                                   ),
                                 ],
                             ),
                              ),
                            ),
                          ),
                        ),
                     ///Active state  Circle
                     //TODO connection state {snapshot.connectionState} (result : message = ConnectionState.active/waiting)
//                     Positioned(
//                       bottom: imageTop * 2.50,
//                       right: imageLeft * 1.40,
//                       child: CircleAvatar(
//                         radius: 15.0,
//                         backgroundColor:  Colors.green,),
//                     ),




                   ]
               ),
             ),
           );
           onilne.add(pages);
//           final onlineUser = OnlinePerson(userEmail,userID,nickName,url,about);
//           onlinePerson.add(onlineUser);
         }
        }
           return  Expanded(
               child: LiquidSwipe(
                 pages: onilne,
                 fullTransitionValue: 200,
                 enableSlideIcon: true,
                 enableLoop: true,
                 positionSlideIcon: 0.5,
                 onPageChangeCallback: pageChangeCallback,
                 currentUpdateTypeCallback: updateTypeCallback,
                 waveType: WaveType.liquidReveal,
               )

           );
      },
    );
  }

  pageChangeCallback(int lpage) {
    print(lpage);
    setState(() {
     _clipColors = _colors[Random().nextInt(4)];
      page = lpage;
    });
  }
  updateTypeCallback(UpdateType updateType) {
    print(updateType);
  }
}







