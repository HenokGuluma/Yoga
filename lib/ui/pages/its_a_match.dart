import 'dart:async';
import 'dart:ui';
import 'package:async/async.dart';
import 'dart:math';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tinder_clone/bloc/authentication/authentication_bloc.dart';
import 'package:tinder_clone/bloc/messaging/messaging_bloc.dart';
import 'package:tinder_clone/models/message.dart';
import 'package:tinder_clone/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tinder_clone/bloc/search/search_bloc.dart';
import 'package:tinder_clone/repositories/messageRepository.dart';
import 'package:tinder_clone/repositories/messaging.dart';
import 'package:tinder_clone/repositories/searchRepository.dart';
import 'package:tinder_clone/repositories/userRepository.dart';

import 'edit_profile_screen.dart';
import 'home.dart';

class ItsAMatch extends StatefulWidget {
  User currentuser;
  User selecteduser;
  ItsAMatch({this.currentuser, this.selecteduser});

  @override
  _ItsAMatchState createState() => _ItsAMatchState();
}

class _ItsAMatchState extends State<ItsAMatch> with AutomaticKeepAliveClientMixin {
  bool loading = true;
  UserRepository userRepository = UserRepository();
  MessageRepository _messageRepository = MessageRepository();
  MessagingRepository _messagingRepository = MessagingRepository();
  TextEditingController _messageContoller = TextEditingController();
  MessagingBloc _messagingBloc;
  bool isValid = false;


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _messagingBloc = MessagingBloc(messagingRepository: _messagingRepository);

    _messageContoller.text = '';
    _messageContoller.addListener(() {
      setState(() {
        isValid = (_messageContoller.text.isEmpty) ? false : true;
      });
    });
  }


  logOut(){
    BlocProvider.of<AuthenticationBloc>(context)
        .add(LoggedOut());
    /* Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) {
          return Home(userRepository: widget.currentuserRepository);
        }));*/
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: ((context) => Home(userRepository: userRepository))), (Route<dynamic> route) => false,);
  }

  void _onFormSubmitted() {
    print("Message Submitted");

    _messagingBloc.add(
      SendMessageEvent(
        message: Message(
          text: _messageContoller.text,
          senderId: widget.currentuser.uid,
          senderName: widget.currentuser.fullName,
          selectedUserId: widget.selecteduser.uid,
          photo: null,
        ),
      ),
    );
    _messageContoller.clear();
    Fluttertoast.showToast(
        msg: 'Message Sent',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xff00ffff),
        textColor: Colors.black
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
          width: size.width,
          height: size.height,
          child: Container(
              height: size.height*0.9,
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(blurRadius: 1, color: Colors.blue)],
                image: DecorationImage(
                    image: ProgressiveImage(
                        placeholder: AssetImage('assets/profilephoto.png'),
                        // size: 1.87KB
                        //thumbnail:NetworkImage(list[index].data()['postOwnerPhotoUrl']),
                        thumbnail: AssetImage('assets/profilephoto.png'),
                        // size: 1.29MB
                        image: CachedNetworkImageProvider(widget.selecteduser.photo),
                        fit: BoxFit.cover,
                        width:size.width,
                        height: size.height*0.9
                    ).image,
                    fit: BoxFit.cover
                ),
              ),
              child:  new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: size.height*0.05),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: size.width*0.1,
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: size.width*0.05),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.blue
                                ),
                                width: size.width*0.2,
                                height: 40,
                                child: MaterialButton(
                                  child: Text('Skip', style: TextStyle(color: Colors.white, fontSize: 16),),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            )
                          ],
                        ),),
                      Center(
                        child: Text("IT'S A MATCH", style: TextStyle(color: Colors.white, fontSize: 50, fontStyle: FontStyle.italic),),
                      ),
                      Container(
                        width: size.width,
                        height: size.height * 0.1,
                        //color: Colors.white,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: size.width*0.05,
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: TextFormField(
                                  style: TextStyle(color: Colors.white),
                                  validator: (String input) {
                                    if (input.isEmpty) {
                                      return "Please enter message";
                                    }
                                  },
                                  controller: _messageContoller,
                                  decoration: InputDecoration(
                                    hintText: "Send a Message...", hintStyle: TextStyle(color: Colors.white),
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: isValid ? _onFormSubmitted : null,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.height * 0.01),
                                child: Icon(
                                  Icons.send,
                                  size: size.height * 0.03,
                                  color: isValid ? Colors.blue : Colors.grey,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ]
                )/*new Container(
                      decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                    )*/,
              )
          )
        /*Center(
                  child: Text("IT'S A MATCH", style: TextStyle(color: Colors.white, fontSize: 20),),
                ),*/
      ),
      /* ],
        ),
      ),*/
    );
  }

}

