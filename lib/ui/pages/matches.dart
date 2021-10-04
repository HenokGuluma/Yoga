import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:tinder_clone/bloc/matches/bloc.dart';
import 'package:tinder_clone/models/user.dart';
import 'package:tinder_clone/repositories/matchesRepository.dart';
import 'package:tinder_clone/repositories/userRepository.dart';
import 'package:tinder_clone/ui/constants.dart';
import 'package:tinder_clone/ui/pages/friend_profile_screen.dart';
import 'package:tinder_clone/ui/widgets/iconWidget.dart';
import 'package:tinder_clone/ui/widgets/pageTurn.dart';
import 'package:tinder_clone/ui/widgets/photo.dart';
import 'package:tinder_clone/ui/widgets/profile.dart';
import 'package:tinder_clone/ui/widgets/userGender.dart';
import 'package:tinder_clone/ui/widgets/chat.dart' as chat;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'messaging.dart';

class Matches extends StatefulWidget {
  final String userId;

  const Matches({this.userId});

  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  MatchesRepository matchesRepository = MatchesRepository();
  UserRepository userRepository = UserRepository();
  MatchesBloc _matchesBloc;
  int difference;
  bool loadingMatches = true; bool loadingLikes = true;
  List<User> matchedUsers = []; List<User> likes = [];
  Map<String,double> locationMap = Map();
  User currentUser = User();

  getDifference(String id,GeoPoint userLocation) async {
    Position position = await Geolocator.getCurrentPosition();

    double location = await Geolocator.distanceBetween(userLocation.latitude,
        userLocation.longitude, position.latitude, position.longitude);

    //difference = location.toInt();
    locationMap.putIfAbsent(id, () => location);
  }

  Future<void>getMatches(String userID) async {
    matchesRepository.getMatchedUsers(userID).then((matched) {
      print(matched.length.toString() + ' is the number of matches');
      for(int i = 0; i<matched.length; i++){
        matchesRepository.getUserDetails(matched[i]).then((value) {
          setState(() {
            matchedUsers.add(value);
            getDifference(value.uid, value.location);
          });
        });
      }
      setState(() {
        loadingMatches = false;
      });
    });
  }
  Future<void >getCurrentUser() async {
    userRepository.getCurrentUser().then((value) {
      setState(() {
        currentUser = value;
      });
    });
  }
  Future<void>getLikes(String userID) async {
    matchesRepository.getLikes(userID).then((matched) {
      for(int i = 0; i<matched.length; i++){
        matchesRepository.getUserDetails(matched[i]).then((value) {
          setState(() {
            likes.add(value);
            getDifference(value.uid, value.location);
          });
        });
      }
      setState(() {
        loadingLikes = false;
      });
      print('length of likes is '+likes.length.toString());
    });
  }

  @override
  void initState() {
    _matchesBloc = MatchesBloc(matchesRepository: matchesRepository);
    getCurrentUser().then((value) {
      getMatches(widget.userId).then((value) {
      });
      getLikes(widget.userId).then((value) {
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      width: size.width,
      child: ListView(
          children: <Widget>[
            Container(
              height: size.height*0.1,
              child: Padding(
                padding: EdgeInsets.only(left: size.width*0.05, top: size.height*0.05),
                child: Text(
                  "Matched Users",
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.only(left: size.width*0.02),
                height: size.height*0.3,
                child: loadingMatches
                    ?Center(
                  child: CircularProgressIndicator(color: Colors.blue,),
                )
                    :matchedUsers.isEmpty
                    ? Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('No matches yet.', style: TextStyle(color: Color(0xff777777), fontSize: 14, fontWeight: FontWeight.w400),),
                )
                    : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(
                            builder: ((context) => FriendProfileScreen(user: matchedUsers[index], messageAccess: true,))
                        ));
                      },
                      child: MatchGridItem(
                        currentUser: currentUser,
                        user: matchedUsers[index],
                        locationMap: locationMap,
                      ),
                    );
                  },
                  itemCount: matchedUsers.length,
                  scrollDirection: Axis.horizontal,
                )
            ),
            Container(
              height: size.height*0.1,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Someone Likes You",
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.only(left: size.width*0.02),
                height: size.height*0.3,
                child: loadingLikes
                    ?Center(
                  child: CircularProgressIndicator(color: Colors.blue,),
                )
                    :likes.isEmpty
                    ? Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('No new likes yet.', style: TextStyle(color: Color(0xff777777), fontSize: 14, fontWeight: FontWeight.w400),),
                )
                    : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(
                            builder: ((context) => FriendProfileScreen(user: likes[index], messageAccess: true,))
                        ));
                      },
                      child: MatchGridItem(
                        currentUser: currentUser,
                        user: likes[index],
                        locationMap: locationMap,
                      ),
                    );
                  },
                  itemCount: likes.length,
                  scrollDirection: Axis.horizontal,
                )
            ),
          ]
      ),
    );
  }
}

class MatchGridItem extends StatefulWidget {
  final User user;
  final User currentUser;
  final Map<String,double> locationMap;

  MatchGridItem({this.user, this.currentUser, this.locationMap});

  @override
  MatchGridItemstate createState() => MatchGridItemstate();
}

class MatchGridItemstate extends State<MatchGridItem> {

  openChat() async {
    try {
      pageTurn(Messaging(currentUser: widget.currentUser, selectedUser: widget.user),
          context);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context){

    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(left: size.height * 0.01, right: size.height * 0.01 ),
      child: Container(
        width: size.width*0.5,
        height: size.height*0.7,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ProgressiveImage(
              placeholder: AssetImage('assets/profilephoto.png'),
              // size: 1.87KB
              //thumbnail:NetworkImage(list[index].data()['postOwnerPhotoUrl']),
              thumbnail: AssetImage('assets/profilephoto.png'),
              // size: 1.29MB
              image: CachedNetworkImageProvider(widget.user.photo),
              //image: NetworkImage(_currentUser.photoUrl),
              fit: BoxFit.cover,
              width: size.width * 0.4,
              height: size.width*0.4,
            ).image,
            fit: BoxFit.cover,
          ),
          /*boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 5.0,
              spreadRadius: 2.0,
              offset: Offset(10.0, 10.0),
            )
          ],*/
          borderRadius: BorderRadius.circular(size.height * 0.02),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            /* Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.height * 0.02),
                child: PhotoWidget(
                  photoLink: user.photo,
                ),
              ),
            )*/
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.transparent, Colors.black54,
                    Colors.black87, Colors.black],
                      stops: [0.5, 0.7, 0.8, 0.9],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(size.height * 0.02),
                    bottomRight: Radius.circular(size.height * 0.02),
                  )),
              width: size.width * 0.9,
              height: size.height * 0.3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                child: Container(
                  height: size.height * 0.3,
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        height: size.height * 0.1,
                      ),
                      Row(
                        children: <Widget>[
                          //userGender(user.gender),
                          Expanded(
                            child: Text(
                              " " +
                                  widget.user.fullName +
                                  ", " +
                                  (DateTime.now().year - widget.user.age.toDate().year)
                                      .toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16),
                            ),
                          )
                        ],
                      ),
                      /*SizedBox(
                        height: 10,
                      ),*/
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 15,
                              ),
                              Text(
                                widget.locationMap.containsKey(widget.user.uid)
                                    ? (widget.locationMap[widget.user.uid] / 1000).floor().toString() +
                                    "km away"
                                    : "away",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: size.width*0.01),
                            child: GestureDetector(
                                onTap: () async{
                                  await openChat();
                                  /* Navigator.push(context, MaterialPageRoute(
                                      builder: ((context) => Messaging(currentUser: currentUser, selectedUser: user))
                                  ));*/
                                },
                                child: SvgPicture.asset("assets/email.svg", width: 20, height: 20, color: Colors.white)),
                          )
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ) ;
  }
}
