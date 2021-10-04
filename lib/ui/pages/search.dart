import 'package:flutter_svg/svg.dart';
import 'package:tinder_clone/bloc/search/bloc.dart';
import 'package:tinder_clone/models/user.dart';
import 'package:tinder_clone/repositories/searchRepository.dart';
import 'package:tinder_clone/repositories/userRepository.dart';
import 'package:tinder_clone/ui/pages/friend_profile_screen.dart';
import 'package:tinder_clone/ui/widgets/iconWidget.dart';
import 'package:tinder_clone/ui/widgets/photo.dart';
import 'package:tinder_clone/ui/widgets/profile.dart';
import 'package:tinder_clone/ui/widgets/userGender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swipe_cards/swipe_cards.dart';

import 'its_a_match.dart';


class Search extends StatefulWidget {
  final String userId;

  const Search({this.userId});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final SearchRepository _searchRepository = SearchRepository();
  UserRepository _userRepository = UserRepository();
  SearchBloc _searchBloc;
  User _user, _currentUser;
  int difference;
  List<User> retrievedUsers;
  int userIndex = 0;
  bool gettingUsers = true;
  Map<String,double> locationMap = Map();
  List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine _matchEngine;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();




  @override
  void initState() {

    getCurrentUser().then((value) {
      loadingUsers(widget.userId);
    });
    super.initState();
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }
  getDifference(String id, GeoPoint userLocation) async {
    Position position = await Geolocator.getCurrentPosition();

    double location = await Geolocator.distanceBetween(userLocation.latitude,
        userLocation.longitude, position.latitude, position.longitude);

    //difference = location.toInt();
    locationMap.putIfAbsent(id, () => location);
  }

  Future<void>retrieveUsers(String userID) async{
    _searchRepository.getUsers(userID).then((list) {
      setState(() {
        retrievedUsers = list;
        _swipeItems.clear();
        print('retrieved users amount is '+ retrievedUsers.length.toString());
        for(int i = 0; i<retrievedUsers.length; i++){
          getDifference(retrievedUsers[i].uid, retrievedUsers[i].location);
        }
        for (int i = 0; i < retrievedUsers.length; i++) {
          _swipeItems.add( SwipeItem(
              content: Content(user: retrievedUsers[i]),
              //SwipingItem(user: retrievedUsers[i], locationMap: locationMap,),
              likeAction: () async {
                bool matched = await _searchRepository.chooseThisUser(
                    widget.userId,
                    retrievedUsers[i].uid,
                    retrievedUsers[i].fullName,
                    retrievedUsers[i].photo );
                if(matched){
                  setState((){
                    itsAMatch(_currentUser, retrievedUsers[i]);
                    print('Wooohooo, its a match');
                  });
                }
                //${retrievedUsers[i].fullName}
                print('you liked  $matched');
              },
              nopeAction: () {
                _searchRepository.passThisUser(widget.userId, retrievedUsers[i].uid);
              },
              superlikeAction: () {
                _searchRepository.superLikeThisUser(
                    widget.userId,
                    retrievedUsers[i].uid,
                    retrievedUsers[i].fullName,
                    retrievedUsers[i].photo ).then((value) {
                  if(value){
                    itsAMatch(_currentUser, retrievedUsers[i]);
                  }
                });
              }));
          print(retrievedUsers[i].fullName);
        }
        gettingUsers = false;
        _matchEngine = MatchEngine(swipeItems: _swipeItems);
        print(_swipeItems.length.toString() + ' is the number of swipe items');
      });
    });
  }
  loadingUsers(String userID){
    setState(() {
      retrievedUsers = [];
      userIndex = 0;
      gettingUsers = true;
    });
    retrieveUsers(userID).then((value) {
      /* setState(() {
        gettingUsers = false;
      });*/
    });
  }
  Future<void >getCurrentUser() async {
    _userRepository.getUserDetail(userId: widget.userId).then((value) {
      setState(() {
        _currentUser = value;
      });
    });
  }

  itsAMatch(User currentUser, User selectedUser){
    Navigator.push(context, MaterialPageRoute(
        builder: ((context) => ItsAMatch(currentuser: currentUser, selecteduser: selectedUser,))));
  }

  searchWidget(){
    Size size = MediaQuery.of(context).size;
    if (gettingUsers) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.blue),
        ),
      );
    }
    else if (retrievedUsers.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                //border: Border.all(color: Color(0xff00ffff)),
                image: DecorationImage(
                  image: ProgressiveImage(
                    placeholder: AssetImage('assets/profilephoto.png'),
                    // size: 1.87KB
                    //thumbnail:NetworkImage(list[index].data()['postOwnerPhotoUrl']),
                    thumbnail: AssetImage('assets/profilephoto.png'),
                    // size: 1.29MB
                    image: _currentUser==null
                        ?AssetImage('assets/profilephoto.png')
                        :CachedNetworkImageProvider(_currentUser.photo),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width*0.4,
                    height: MediaQuery.of(context).size.width*0.4,
                  ).image,
                  fit: BoxFit.cover,
                ),
              ),
              width: MediaQuery.of(context).size.width*0.4,
              height: MediaQuery.of(context).size.width*0.4,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width*0.1,
            ),
            Text(
              "There is no one new around you for now",
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff555555)),
            )
          ],
        ),
      );
    }
    else
      return Container(
          height: size.height*0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Container(
                height: size.height*0.72,
                child:
                SwipeCards(
                  matchEngine: _matchEngine,
                  itemBuilder: (BuildContext context, int index) {
                    return SwipingItem(
                        user: _swipeItems[index].content.user, locationMap: locationMap)
                    ;
                  },
                  onStackFinished: (){
                    loadingUsers(widget.userId);
                  },
                ),
              ),
              Container(
                height: size.height*0.07,
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black38,
                        //backgroundBlendMode: BlendMode.clear
                      ),
                      child: iconWidget(Icons.clear, () {
                        /* _searchRepository.passThisUser(widget.userId, retrievedUsers[userIndex].uid);
                        updateIndex(userIndex, widget.userId);*/
                        _matchEngine.currentItem.nope();
                      }, size.height * 0.03, Colors.white),
                      height: size.height*0.08,
                      width: size.height*0.08,
                    ),
                    Container(
                      width: 80,
                      height: 50,
                      decoration: BoxDecoration(
                        //border: Border.all(),
                          borderRadius: BorderRadius.circular(30),
                          shape: BoxShape.rectangle,
                          gradient: LinearGradient(colors: [Colors.red, Colors.pinkAccent],
                              stops: [0.1, 0.9],
                              begin: Alignment.centerLeft, end: Alignment.centerRight)
                        //color: Colors.p,
                        //backgroundBlendMode: BlendMode.difference
                      ),
                      child: iconWidget(Icons.star_border, () {
                        /* _searchRepository.superLikeThisUser(
                            widget.userId,
                            retrievedUsers[userIndex].uid,
                            retrievedUsers[userIndex].fullName,
                            retrievedUsers[userIndex].photo ).then((value) {
                          if(value){
                            itsAMatch(_currentUser, retrievedUsers[userIndex]);
                          }
                        });
                        updateIndex(userIndex, widget.userId);*/
                        _matchEngine.currentItem.superLike();
                      }, size.height * 0.04,
                          Colors.white),
                    ),
                    Container(
                        width: size.height*0.08,
                        height: size.height*0.08,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue
                        ),
                        child: IconButton(
                          icon:
                          /*Icon(Icons.favorite_border_sharp, color: Colors.red, size: size.height*0.05,),*/
                          SvgPicture.asset("assets/heart_fill.svg", width: size.height * 0.03, height: size.height * 0.03, color: Colors.white),
                          onPressed: (){
                            /*_searchRepository.chooseThisUser(
                                widget.userId,
                                retrievedUsers[userIndex].uid,
                                retrievedUsers[userIndex].fullName,
                                retrievedUsers[userIndex].photo ).then((value) {
                              if(value){
                                itsAMatch(_currentUser, retrievedUsers[userIndex]);
                              }
                            });
                            updateIndex(userIndex, widget.userId);*/
                            _matchEngine.currentItem.like();
                          },
                        )
                    ),
                  ],
                ),
              )
            ]
            ,)
      ) ;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: searchWidget(),
    );
  }
}

class Content{
  final User user;
  Content({this.user});
}

class SwipingItem extends StatefulWidget{
  User user;
  Map<String,double> locationMap;
  SwipingItem({this.user, this.locationMap});

  @override
  _SwipingItemState createState() => _SwipingItemState();
}
class _SwipingItemState extends State<SwipingItem>{

  @override
  Widget build(BuildContext context){

    Size size = MediaQuery.of(context).size;
    return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: ((context) => FriendProfileScreen(user: widget.user, messageAccess: false,))));
        },
        child:Padding(
          padding: EdgeInsets.only(left: size.height * 0.03, right: size.height * 0.03, top: size.height * 0.01, bottom: size.height*0.01 ),
          child: Container(
            height: size.height,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                  offset: Offset(10.0, 10.0),
                )
              ],
              borderRadius: BorderRadius.circular(size.height * 0.02),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Container(
                  width: size.width * 0.95,
                  height: size.height * 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size.height * 0.02),
                    child: PhotoWidget(
                      photoLink: widget.user.photo,
                    ),
                  ),
                ),
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
                      height: size.height * 0.7,
                      child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: size.height * 0.06,
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
                                      fontSize: 20),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              Text(
                                widget.locationMap.containsKey(widget.user.uid)
                                    ? (widget.locationMap[widget.user.uid] / 1000).floor().toString() +
                                    "km away"
                                    : "away",
                                style: TextStyle(color: Colors.white),
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
        )) ;
  }
}
