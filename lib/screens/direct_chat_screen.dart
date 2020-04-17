import 'dart:io';

import 'package:flash_chat/components/avatar.dart';
import 'package:flash_chat/screens/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flash_chat/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';


final  _firestore = Firestore.instance;
FirebaseUser loggedInUser;
String groupChatId;
String _partnerNickName;
class DirectChatScreen extends StatefulWidget {
  static String id='DirectChatScreen';
  final String partnerNickName;
  final String partnerID;
  final String photoUrl;
  DirectChatScreen(this.partnerNickName,this.partnerID,this.photoUrl);
  @override
  _DirectChatScreenState createState() => _DirectChatScreenState(partnerNickName,partnerID,photoUrl);
}

class _DirectChatScreenState extends State<DirectChatScreen> {
   String partnerNickName;
   String partnerID;
   String photoUrl;
  _DirectChatScreenState(this.partnerNickName,this.partnerID,this.photoUrl);
  final _auth=FirebaseAuth.instance;
   String messageText;

   final messageTextController = TextEditingController();
   final listScrollController = ScrollController();
   File imageFile;
   String imageUrl;
   bool isLoading;




   @override
  void initState() {
     super.initState();
     groupChatId = '';
     imageUrl = '';
     isLoading = false;
     getCurrentUser();
     makeGroup();


     _partnerNickName = partnerNickName;
   }

   //get current user
  void getCurrentUser() async{
    try{
      final user = await _auth.currentUser();
      if(user != null){
        loggedInUser = user;

      }}catch(e){
      print(e);
    }
  }

  //make a group foreach partners
   makeGroup() async {
       loggedInUser.uid.hashCode <= partnerID.hashCode ?
      groupChatId =   '${loggedInUser.uid}-$partnerID'
       :
       groupChatId = '$partnerID-${loggedInUser.uid}';

   }

   Future getImage() async {
     imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
     if (imageFile != null) {
       setState(() {
         isLoading = true;
       });
       uploadFile();
     }
   }

   Future uploadFile() async {
     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
     StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
     StorageUploadTask uploadTask = reference.putFile(imageFile);
     StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
     storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
       imageUrl = downloadUrl;
       setState(() {
         isLoading = false;
         onSendMessage(imageUrl, 1);
       });
     }, onError: (err) {
       setState(() {
         isLoading = false;
       });
       Fluttertoast.showToast(msg: 'This file is not an image');
     });
   }


   /// build a collection when send a message and store messages
   void onSendMessage(String content,int type) async{
     // type: 0 = text, 1 = image, 2 = sticker
     if (content.trim() != '') {
       messageTextController.clear();


       final snapShot = await _firestore
           .collection('messages')
           .document(groupChatId)
           .get();
          var documentReference;
       if (snapShot == null || !snapShot.exists) {
       // Document with id == docId doesn't exist.
        documentReference = _firestore
           .collection('messages')
           .document(groupChatId)
           .collection(groupChatId)
           .document(DateTime
           .now()
           .millisecondsSinceEpoch
           .toString());

       _firestore.runTransaction((transaction) async {
         await transaction.set(
           documentReference,
           {
             'idFrom': loggedInUser.uid,
             'idTo': partnerID,
             'timestamp': DateTime.now().toString(),
             'content': content,
             'type':type
           },
         );
       });}

 else{
         documentReference.add({
           'timestamp': DateTime.now().toString(),
           'content': content,
           'type':type
         });
       }
       listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
     } else {
       Fluttertoast.showToast(msg: 'Nothing to send');
     }
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBodyColor,
      appBar: AppBar(

              title: Align(
                  alignment: Alignment.center,

                  child: Row(
                    children: <Widget>[
                      photoUrl != ''
                          ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              backgroundColor: kbackProgressColor,
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(kValueProgressColor),),
                            width: 40.0,
                            height: 40.0,
                            padding: EdgeInsets.all(20.0),),
                          imageUrl: photoUrl,
                          width: 40.0,
                          height: 40.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(45.0)),
                        clipBehavior: Clip.hardEdge,
                      ) : Avatar(20.0,Colors.blueGrey,Colors.lightBlueAccent),
                      Text(partnerNickName),
                    ],
                  )),
        ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                   Container(
                    margin: new EdgeInsets.symmetric(horizontal: 1.0),
                    child: new IconButton(
                      icon: new Icon(Icons.image,color: logoColor,),
                      onPressed: getImage,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration.copyWith(
                        hintText: 'Type your message here',
                        hintStyle: TextStyle(color : Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send,color: logoColor,),
                    onPressed: (){
                       messageTextController.clear();
                      //Implement send functionality.
                      //messageText + sender
                      onSendMessage(messageText,0);},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').
          document(groupChatId)
          .collection(groupChatId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder:  (context, snapshot) {
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: kbackProgressColor,
              valueColor: AlwaysStoppedAnimation<Color>(kValueProgressColor),
            ),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];

        for(var message in messages){
          final messageContent = message.data['content'];
          final type = message.data['type'];
          final currentUser = loggedInUser.uid;
          final messageSender = message.data['idFrom'];
          final messageTime = message.data['timestamp'];

          final messageBubble = MessageBubble(sender: messageSender,content: messageContent,isMe:
            currentUser == messageSender,nickname:_partnerNickName,type: type,time: messageTime,);
          messageBubbles.add(messageBubble);

        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
            children: messageBubbles,
          ),
        );

      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender,this.content,this.isMe,this.nickname,this.type,this.time});
  final String content;
  final String sender;
  final bool isMe;
  final String nickname;
  final int type;
  final String time;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end :  CrossAxisAlignment.start ,
          children:
         <Widget>[
            isMe ?  StreamBuilder(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: kbackProgressColor,
                      valueColor: AlwaysStoppedAnimation<Color>(kValueProgressColor),

                    ),

                  );
                }
                final List<DocumentSnapshot> infos = snapshot.data.documents;
                int i = 0;
                var nickname = '';
                while (i < infos.length) {
                  if (infos[i]['id'] == loggedInUser.uid) {
                    nickname = infos[i]['nickname'];
                  }
                  i++;
                }
                return Text(nickname, style: TextStyle(
                    fontSize: 12.0, color: Colors.black54),);
              }) : Text( _partnerNickName ,style: TextStyle(
                fontSize: 12.0,
                color: Colors.black54
            ),),
           type == 0 ?  Material(
              elevation: 5.0,
              borderRadius:
              isMe ? BorderRadius.only(topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0))
                  :  BorderRadius.only(bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  topRight: Radius.circular(30.0)),
              color: isMe ? logoColor:  kPartnerMessageBubble ,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
                child: Text(content,style:
                TextStyle(fontSize: 15.0,color: Colors.white),),
              ),

            ):
           Container(
             child: FlatButton(
               child: Material(
                 child: CachedNetworkImage(
                   placeholder: (context, url) => Container(
                     child: CircularProgressIndicator(
                       backgroundColor: kbackProgressColor,
                       valueColor: AlwaysStoppedAnimation<Color>(kValueProgressColor),
                     ),
                     width: 200.0,
                     height: 200.0,
                     padding: EdgeInsets.all(70.0),
                     decoration: BoxDecoration(
                       color: isMe ? Color(0xffaeaeae) : Color(0xffE8E8E8),
                       borderRadius: BorderRadius.all(
                         Radius.circular(8.0),
                       ),
                     ),
                   ),
                   errorWidget: (context, url, error) => Material(
                     child: Image.asset(
                       'images/img_not_available.jpeg',
                       width: 200.0,
                       height: 200.0,
                       fit: BoxFit.fill,
                     ),
                     borderRadius: BorderRadius.all(
                       Radius.circular(8.0),
                     ),
                     clipBehavior: Clip.hardEdge,
                   ),
                   imageUrl: content,
                   width: 200.0,
                   height: 200.0,
                   fit: BoxFit.fill,
                 ),
                 borderRadius: BorderRadius.all(Radius.circular(8.0)),
                 clipBehavior: Clip.hardEdge,
               ),
               onPressed: () {
                 ImageView(url:content).showImage(context);
               },
               padding: EdgeInsets.all(0),
             ),
             margin: EdgeInsets.only(bottom: isMe ? 20.0 : 10.0, right: 10.0),
           ),


           Text(editingTime(time),style:
           TextStyle(fontSize: 15.0,color: Colors.grey),),

         ]


      ),
    );
  }
}


