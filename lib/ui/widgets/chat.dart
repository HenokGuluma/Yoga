import 'package:tinder_clone/models/chat.dart';
import 'package:tinder_clone/models/message.dart';
import 'package:tinder_clone/models/user.dart';
import 'package:tinder_clone/repositories/messageRepository.dart';
import 'package:tinder_clone/ui/pages/messaging.dart';
import 'package:tinder_clone/ui/widgets/pageTurn.dart';
import 'package:tinder_clone/ui/widgets/photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatWidget extends StatefulWidget {
  final String userId, selectedUserId;
  final Timestamp creationTime;

  const ChatWidget({this.userId, this.selectedUserId, this.creationTime});

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  MessageRepository messageRepository = MessageRepository();
  Chat chat;
  User user;
  User currentUser;
  Map<String, User> map = Map();

  getUserDetail() async {
    user = await messageRepository.getUserDetail(userId: widget.selectedUserId);
    map.putIfAbsent(widget.selectedUserId, () => user);
    Message message = await messageRepository
        .getLastMessage(
        currentUserId: widget.userId, selectedUserId: widget.selectedUserId)
        .catchError((error) {
      print(error);
    });

    if (message == null) {
      return Chat(
        name: user.fullName,
        photoUrl: user.photo,
        lastMessage: null,
        lastMessagePhoto: null,
        timestamp: null,
      );
    } else {
      return Chat(
        name: user.fullName,
        photoUrl: user.photo,
        lastMessage: message.text,
        lastMessagePhoto: message.photoUrl,
        timestamp: message.timestamp,
      );
    }
  }

  openChat() async {
    try {
      pageTurn(Messaging(currentUser: currentUser, selectedUser: map[widget.selectedUserId]),
          context);
    } catch (e) {
      print(e.toString());
    }
  }

  deleteChat() async {
    await messageRepository.deleteChat(
        currentUserId: widget.userId, selectedUserId: widget.selectedUserId);
  }
  @override
  void initState() {
    super.initState();
    messageRepository.getUserDetail(userId: widget.userId).then((value){
      setState(() {
        currentUser = value;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder(
      future: getUserDetail(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          Chat chat = snapshot.data;
          return GestureDetector(
            onTap: () async {
              await openChat();
            },
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    content: Wrap(
                      children: <Widget>[
                        Text(
                          "Do you want to delete this chat",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "This action is irreversible.",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "No",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await deleteChat();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ));
            },
            child: Padding(
              padding: EdgeInsets.all(size.height * 0.02),
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.height * 0.02),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        ClipOval(
                          child: Container(
                            height: 40,
                            width: 40,
                            child: PhotoWidget(
                              photoLink: user.photo,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              user.fullName,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
                            ),
                            chat.lastMessage != null
                                ? Container(
                              width: size.width*0.5,
                              child: Text(
                                chat.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                                : chat.lastMessagePhoto == null
                                ? Text("Chat Room Open")
                                : Row(
                              children: <Widget>[
                                Icon(
                                  Icons.photo,
                                  color: Colors.grey,
                                  size:14,
                                ),
                                Text(
                                  "Photo",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                        width: size.width*0.2,
                        child:chat.timestamp != null
                            ? Text(timeago.format(chat.timestamp.toDate()), maxLines: 1,
                          overflow: TextOverflow.ellipsis,)
                            : Text(timeago.format(widget.creationTime.toDate()), maxLines: 1,
                          overflow: TextOverflow.ellipsis,)
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
