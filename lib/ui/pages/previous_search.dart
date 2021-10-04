import 'package:flutter_svg/svg.dart';
import 'package:tinder_clone/bloc/search/bloc.dart';
import 'package:tinder_clone/models/user.dart';
import 'package:tinder_clone/repositories/searchRepository.dart';
import 'package:tinder_clone/repositories/userRepository.dart';
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

class PreviousSearch extends StatefulWidget {
  final String userId;

  const PreviousSearch({this.userId});

  @override
  _PreviousSearchState createState() => _PreviousSearchState();
}

class _PreviousSearchState extends State<PreviousSearch> {
  final SearchRepository _searchRepository = SearchRepository();
  UserRepository _userRepository = UserRepository();
  SearchBloc _searchBloc;
  User _user, _currentUser;
  int difference;
  List<User> retrievedUsers;
  int userIndex;
  bool gettingUsers = true;

  getDifference(GeoPoint userLocation) async {
    Position position = await Geolocator.getCurrentPosition();

    double location = await Geolocator.distanceBetween(userLocation.latitude,
        userLocation.longitude, position.latitude, position.longitude);

    difference = location.toInt();
  }

  Future<void>retrieveUsers(String userID) async{
    _searchRepository.getUsers(userID).then((list) {
      setState(() {
        retrievedUsers = list;
      });
    });
  }
  loadingMoreUsers(String userID){
    setState(() {
      gettingUsers = true;
    });
    retrieveUsers(userID).then((value) {
      setState(() {
        gettingUsers = false;
      });
    });
  }
  Future<void >getCurrentUser() async {
    _userRepository.getUserDetail(userId: widget.userId).then((value) {
      setState(() {
        _currentUser = value;
      });
    });
  }

  @override
  void initState() {
    _searchBloc = SearchBloc(searchRepository: _searchRepository);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<SearchBloc, SearchState>(
      bloc: _searchBloc,
      builder: (context, state) {
        if (gettingUsers) {
          /* _searchBloc.add(
            LoadUserEvent(userId: widget.userId),
          );*/
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          );
        }
        if (state is LoadingState) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          );
        }
        if (state is LoadUserState) {
          _user = state.user;
          _currentUser = state.currentUser;

          getDifference(_user.location);
          if (_user.location == null) {
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
                          image: CachedNetworkImageProvider(_currentUser.photo),
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
          } else
            return Container(
                height: size.height*0.75,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.height * 0.035, right: size.height * 0.035, top: size.height * 0.035, bottom: 20 ),
                      child: Container(
                        height: size.height*0.7,
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
                                  photoLink: _user.photo,
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
                                          userGender(_user.gender),
                                          Expanded(
                                            child: Text(
                                              " " +
                                                  _user.fullName +
                                                  ", " +
                                                  (DateTime.now().year - _user.age.toDate().year)
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
                                            difference != null
                                                ? (difference / 1000).floor().toString() +
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
                    ),
                    Container(
                      height: size.height*0.05,
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
                              _searchBloc
                                  .add(PassUserEvent(widget.userId, _user.uid));
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
                            child: iconWidget(Icons.star_border, () {}, size.height * 0.04,
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
                                _searchBloc.add(
                                  SelectUserEvent(
                                      name: _currentUser.fullName,
                                      photoUrl: _currentUser.photo,
                                      currentUserId: widget.userId,
                                      selectedUserId: _user.uid),
                                );
                              },
                            )/*IconWidget(SvgPicture.asset("assets/email.svg", width: size.height * 0.04, height: size.height * 0.04, color: Colors.red), () {
                           _searchBloc.add(
                             SelectUserEvent(
                                 name: _currentUser.fullName,
                                 photoUrl: _currentUser.photo,
                                 currentUserId: widget.userId,
                                 selectedUserId: _user.uid),
                           );
                         }, size.height * 0.04, Colors.red)*/,
                          ),
                        ],
                      ),
                    )
                  ]
                  ,)
            ) ;
        }
        else
          return Container()
          ;
      },
    );
  }
}
