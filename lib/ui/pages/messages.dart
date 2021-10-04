import 'package:flutter/cupertino.dart';
import 'package:tinder_clone/bloc/message/bloc.dart';
import 'package:tinder_clone/repositories/messageRepository.dart';
import 'package:tinder_clone/ui/widgets/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Messages extends StatefulWidget {
  final String userId;
  Messages({this.userId});
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  MessageRepository _messagesRepository = MessageRepository();
  MessageBloc _messageBloc;

  @override
  void initState() {
    _messageBloc = MessageBloc(messageRepository: _messagesRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocBuilder<MessageBloc, MessageState>(
      bloc: _messageBloc,
      builder: (BuildContext context, MessageState state) {
        if (state is MessageInitialState) {
          _messageBloc.add(ChatStreamEvent(currentUserId: widget.userId));
        }
        if (state is ChatLoadingState) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ChatLoadedState) {
          Stream<QuerySnapshot> chatStream = state.chatStream;

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: size.height*0.02, top: size.height*0.02),
                child: Container(
                  height: size.height*0.03,
                  child: Text('Messages', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: chatStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text("No conversations", style: TextStyle(color: Color(0xff999999)),),
                    );
                  }

                  if (snapshot.data.docs.isNotEmpty) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.blue,),
                      );
                    } else {
                      return Container(
                        height: size.height*0.8-50,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot user = snapshot.data.docs[index];
                            Map userData = user.data();
                            return ChatWidget(
                              creationTime: userData['timestamp'],
                              userId: widget.userId,
                              selectedUserId: user.id,
                            );
                          },
                        ),
                      );
                    }
                  } else
                    return Center(
                      child: Text("No conversations", style: TextStyle(color: Color(0xff999999)),),
                    );
                },
              )
            ],
          );
        }
        return Container();
      },
    );
  }
}
