import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

class ImageView  {
  final String url;

  const ImageView({this.url});

      Widget getImage(){
        return Material(
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                backgroundColor: kbackProgressColor,
                valueColor: AlwaysStoppedAnimation<Color>(kValueProgressColor),
              ),
              width: 500.0,
              height: 500.0,
              padding: EdgeInsets.all(70.0),
              decoration: BoxDecoration(
                color: Color(0xffE8E8E8),
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Material(
              child: Image.asset(
                'images/img_not_available.jpeg',
                width: 500.0,
                height: 500.0,
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
            imageUrl: url,
            width: 500.0,
            height: 500.0,
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          clipBehavior: Clip.hardEdge,
        );
      }


  Future<bool> showImage(BuildContext context) {
       return
         showDialog(context: context,builder:
       (context) =>
         AlertDialog(
           backgroundColor: Colors.transparent,
          content: Stack(
           overflow: Overflow.visible,
           children: <Widget>[
               getImage(),
             Positioned(
               right: -15.0,
               top: -15.0,
               child: InkResponse(
                 onTap: () {
                   Navigator.of(context).pop();
                 },
                 child: CircleAvatar(
                   child: Icon(Icons.close),
                   backgroundColor: logoColor,
                 ),
               ),
             ),

           ],
         ),
       )
         ) ??
             false;
     }
  }


