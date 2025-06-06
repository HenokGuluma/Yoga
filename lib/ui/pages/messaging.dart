import 'dart:io';

import 'package:tinder_clone/bloc/messaging/bloc.dart';
import 'package:tinder_clone/bloc/messaging/messaging_bloc.dart';
import 'package:tinder_clone/models/message.dart';
import 'package:tinder_clone/models/user.dart';
import 'package:tinder_clone/repositories/messaging.dart';
import 'package:tinder_clone/repositories/userRepository.dart';
import 'package:tinder_clone/ui/constants.dart';
import 'package:tinder_clone/ui/pages/friend_profile_screen.dart';
import 'package:tinder_clone/ui/widgets/message.dart';
import 'package:tinder_clone/ui/widgets/photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Messaging extends StatefulWidget {
  final User currentUser, selectedUser;

  const Messaging({this.currentUser, this.selectedUser});

  @override
  _MessagingState createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  TextEditingController _messageTextController = TextEditingController();
  MessagingRepository _messagingRepository = MessagingRepository();
  UserRepository _userRepository = UserRepository();
  MessagingBloc _messagingBloc;
  bool isValid = false;

//  bool get isPopulated => _messageTextController.text.isNotEmpty;
//
//  bool isSubmitButtonEnabled(MessagingState state) {
//    return isPopulated;
//  }

  @override
  void initState() {
    super.initState();
    _messagingBloc = MessagingBloc(messagingRepository: _messagingRepository);

    _messageTextController.text = '';
    _messageTextController.addListener(() {
      setState(() {
        isValid = (_messageTextController.text.isEmpty) ? false : true;
      });
    });
  }

  @override
  void dispose() {
    _messageTextController.dispose();
    super.dispose();
  }

  void _onFormSubmitted() {
    print("Message Submitted");

    _messagingBloc.add(
      SendMessageEvent(
        message: Message(
          text: _messageTextController.text,
          senderId: widget.currentUser.uid,
          senderName: widget.currentUser.fullName,
          selectedUserId: widget.selectedUser.uid,
          photo: null,
        ),
      ),
    );
    _messageTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: size.height * 0.02,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              child: ClipOval(
                child: Container(
                  height: size.height * 0.04,
                  width: size.height * 0.04,
                  child: PhotoWidget(
                    photoLink: widget.selectedUser.photo,
                  ),
                ),
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: ((context) => FriendProfileScreen(user: widget.selectedUser, messageAccess: true,))
                ));
              },
            ),
            SizedBox(
              width: size.width * 0.03,
            ),
            Expanded(
              child: Text(widget.selectedUser.fullName, style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w400),),
            ),
          ],
        ),
      ),
      body: BlocBuilder<MessagingBloc, MessagingState>(
        bloc: _messagingBloc,
        builder: (BuildContext context, MessagingState state) {
          if (state is MessagingInitialState) {
            _messagingBloc.add(
              MessageStreamEvent(
                  currentUserId: widget.currentUser.uid,
                  selectedUserId: widget.selectedUser.uid),
            );
          }
          if (state is MessagingLoadingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is MessagingLoadedState) {
            Stream<QuerySnapshot> messageStream = state.messageStream;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                  stream: messageStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        height: size.height*0.7,
                        child: Center(
                          child: Text(
                            "Start the conversation?",
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.w400),
                          ),
                        ),
                      );
                    }
                    if (snapshot.data.docs.isNotEmpty) {
                      return Expanded(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  return MessageWidget(
                                    currentUserId: widget.currentUser.uid,
                                    messageId: snapshot.data.docs[index].id,
                                  );
                                },
                                itemCount: snapshot.data.docs.length,
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        height: size.height*0.7,
                        child: Center(
                          child: Text(
                            "Start the conversation?",
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.w400),
                          ),
                        ),
                      );
                    }
                  },
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.06,
                  //color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          File photo;
                          FilePickerResult getPhoto = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (getPhoto != null) {
                            setState(() {
                              photo = File(getPhoto.files.first.path);
                            });
                            _messagingBloc.add(
                              SendMessageEvent(
                                message: Message(
                                    text: null,
                                    senderName: widget.currentUser.fullName,
                                    senderId: widget.currentUser.uid,
                                    photo: photo,
                                    selectedUserId: widget.selectedUser.uid),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.height * 0.01),
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: size.height * 0.03,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextFormField(
                            style: TextStyle(color: Colors.black),
                            validator: (String input) {
                              if (input.isEmpty) {
                                return "Please enter message";
                              }
                            },
                            controller: _messageTextController,
                            decoration: InputDecoration(
                              hintText: "Send a Message...", hintStyle: TextStyle(color: Colors.black),
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
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
