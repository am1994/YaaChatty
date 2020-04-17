import 'package:flash_chat/screens/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'online_screen.dart';
import 'package:flash_chat/components/drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';



final  _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id= 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {


  final _auth=FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String messageText;
  File imageFile;
  String imageUrl;
  bool isLoading;
  String nickname ;
  @override
  void initState() {
    super.initState();
    nickname = '';
    getCurrentUser();
    messageText = '';
  }

  void getCurrentUser() async{
    try{
    final user = await _auth.currentUser();
    if(user != null){
      loggedInUser = user;
           getUserName();
    }}catch(e){
      print(e);
    }
  }


   void getUserName( ) async {


       _firestore.collection('users').document(loggedInUser.uid).get().then((
           data) {
         setState(() {
           nickname = data.data['nickname'];
           _firestore.collection('messages').add({
             'sender': nickname,
           });
         });


       });


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
  void onSendMessage(String content,int type)  async{
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      messageTextController.clear();
      getUserName();
    await  _firestore.collection('messages').add({
        'sender':  nickname,
        'text': content,
        'id' : loggedInUser.uid,
        'timestamp': DateTime
            .now()
            .toString(),
        'type':type
      });

    }

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
        backgroundColor: kBackgroundBodyColor,
        appBar: AppBar(
            leading:null,
            actions: <Widget>[
              IconButton(icon: Icon(Icons.people,),
                onPressed: () => Navigator.pushNamed(context, OnlineScreen.id),

              ),

            ],
            
            title: Row(children: <Widget>[
              Image.asset('images/chat_icon.png',scale: 2,),
              Text('️Chat')
            ],),
          ),
          drawer: DrawerWidget(),
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
                          icon: new Icon(Icons.image,color: logoColor),
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
                            hintText: 'Type your message here...',
                            hintStyle: TextStyle(color : Colors.grey),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send,color: logoColor,),
                        onPressed: ()async{
                          messageTextController.clear();

                          //Implement send functionality.
                          //messageText + sender
                          onSendMessage(messageText,0);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class MessagesStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages')
              .orderBy('timestamp', descending: true)
              .snapshots(),

      builder:  (context, snapshot) {
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: logoColor,
            ),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];
        for(var message in messages){
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];
          final currentUser = loggedInUser.uid;
          final useUid = message.data['id'];
          final   messageType = message.data['type'];
          final messageTime= message.data['timestamp'];
           print('type $messageType');
          final messageBubble = MessageBubble(sender: messageSender,content: messageText,isMe:
            currentUser == useUid,type: messageType,time: messageTime,);
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
     MessageBubble({this.sender,this.content,this.isMe,this.type,this.time});
     final String content;
     final String sender;
     final bool isMe;
     final int type;
     final String time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end :  CrossAxisAlignment.start ,
        children:   <Widget>[
          Text(sender,style: TextStyle(
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
            color: isMe ? logoColor :  kPartnerMessageBubble ,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
              child: Text(content,style:
                TextStyle(fontSize: 15.0,color: isMe ? Colors.white : Colors.black),),
            ),
        ) : Container(
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
                ImageView(url: content).showImage(context);
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
