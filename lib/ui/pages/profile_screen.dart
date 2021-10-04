import 'dart:async';
import 'package:async/async.dart';
import 'dart:math';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:tinder_clone/bloc/authentication/authentication_bloc.dart';
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
import 'package:tinder_clone/repositories/searchRepository.dart';
import 'package:tinder_clone/repositories/userRepository.dart';

import 'edit_profile_screen.dart';
import 'home.dart';

class ProfileScreen extends StatefulWidget {
  final userId;
  ProfileScreen({this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  User _currentUser = User();
  bool loading = true;
  String header = 'Profile';
  UserRepository _currentUserRepository = UserRepository();
  List<String> previousPhotos =[];


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((value) {
    });
  }
  Future<void >getPreviousPhotos(uid) async {
    _currentUserRepository.previousPhotos(uid).then((photoList) {
      setState(() {
        for(int i=0; i<photoList.length; i++){
          previousPhotos.add(photoList[i]['photoUrl']);
        }
        loading = false;
      });
    });
  }

  Future<void >getCurrentUser() async {
    _currentUserRepository.getUserDetail(userId: widget.userId).then((value) {
      setState(() {
        _currentUser = value;
        loading = false;
      });
      getPreviousPhotos(value.uid);
    });
  }

  String adjustNumbers(int num){
    if (num >= 1000000){
      String num2 = (num/1000000).toStringAsFixed(2) + ' M';
      return num2;
    }
    if(num >=10000){
      String num2 = (num/1000).toStringAsFixed(1) + ' K';
      return num2;
    }
    else{
      String num2 = num.toString();
      return num2;
    }
  }
  logOut(){
    BlocProvider.of<AuthenticationBloc>(context)
        .add(LoggedOut());
   /* Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) {
          return Home(userRepository: _currentUserRepository);
        }));*/
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: ((context) => Home(userRepository: _currentUserRepository))), (Route<dynamic> route) => false,);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        toolbarHeight: 40.0,
        elevation: 1,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.black,)),
        centerTitle: true,
        title: Text(header, style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.w600)),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout) ,
              color: Colors.black,
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      content: Wrap(
                        children: <Widget>[
                          Text(
                            "Do you want to log out?",
                            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
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
                              color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 16
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await logOut();
                          },
                          child: Text(
                            "Yes",
                            style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w400, fontSize: 16
                            ),
                          ),
                        ),
                      ],
                    ));
              }
          )
        ],
      ),
      body: ListView(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: ProgressiveImage(
                        placeholder: AssetImage('assets/profilephoto.png'),
                        // size: 1.87KB
                        //thumbnail:NetworkImage(list[index].data()['postOwnerPhotoUrl']),
                        thumbnail: AssetImage('assets/profilephoto.png'),
                        // size: 1.29MB
                        image: loading
                            ? AssetImage('assets/profilephoto.png')
                        :CachedNetworkImageProvider(_currentUser.photo),
                        //image: NetworkImage(_currentUser.photoUrl),
                        fit: BoxFit.cover,
                        width: size.width * 0.4,
                        height: size.width*0.4,
                      ).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: size.width * 0.4,
                  height: size.width*0.4,
                ),
              ))
          ,
          Center(
            child: Text(loading
                ?'...'
            :'${_currentUser.fullName}, ${(DateTime.now().year - _currentUser.age.toDate().year)
                .toString()}',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 25.0)),
          ),
          loading
              ?Container(
            height: 20,
          )
              :_currentUser.interestedIn.isNotEmpty
              ? Center(
            child: Container(
                  padding: EdgeInsets.only(left: 25, top: 15, bottom: 10),
                  constraints: BoxConstraints(minWidth: 50, maxWidth: MediaQuery.of(context).size.width*0.9),
                  decoration: BoxDecoration(
                  ),
                  child: Text(_currentUser.bio, style: TextStyle(color: Colors.black, fontSize: 16),
                    overflow: TextOverflow.clip,
                    maxLines: 3,
                    //textAlign: TextAlign.justify,
                  ),
                ),
          )
              : Container(),
          loading
              ? Padding(
            padding:  EdgeInsets.only(
                top: 12.0, left: size.width*0.2, right: size.width*0.2),
            child: Container(
              width: size.width*0.5,
              height: 40.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.grey)),
              child: Center(
                child: Text('Edit Profile',
                    style: TextStyle(color: Colors.grey)),
              ),
            ),
          )
              :GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 12.0, left: size.width*0.2, right: size.width*0.2),
              child: Container(
                width: size.width*0.5,
                height: 40.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.blue)),
                child: Center(
                  child: Text('Edit Profile',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: ((context) => EditProfileScreen(
                    id: _currentUser.uid,
                    photoUrl: _currentUser.photo,
                    bio: _currentUser.bio,
                    name: _currentUser.fullName,
                    age: _currentUser.age,
                    gender: _currentUser.gender,
                  ))
              ));
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, top: size.height*0.1),
            child: Text('Previous Photos', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.w500),),
          ),
          Divider(
            color: Colors.blue,
            thickness: 0.5,
          ),
          loading
              ?Container(
            height: size.height*0.1,
            child: Center(
              child: CircularProgressIndicator(color: Colors.blue,),
            ),
          )
              :previousPhotos.length==0
              ?Container(
              height: size.height*0.1,
              child:Center(
                child: Text('No previous photos', style: TextStyle(color: Colors.grey, fontSize: 14),),
              )
          )
              :GridView.builder(

            cacheExtent: 500000,
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: previousPhotos.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2/3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0),
            itemBuilder: ((context, index) {

              return GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(size.width*0.01),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: ProgressiveImage(
                          placeholder: AssetImage('assets/grey.png'),
                          // size: 1.87KB
                          thumbnail: AssetImage('assets/grey.png'),
                          // size: 1.29MB
                          image: CachedNetworkImageProvider(previousPhotos[index]),
                          width: MediaQuery.of(context).size.width/3-1,
                          height: MediaQuery.of(context).size.width/2-1,
                          fit: BoxFit.cover,
                        ).image,
                        fit: BoxFit.cover
                    ),
                  ),
                ),
                onTap: () {
                },
              );
            }),
          )
        ],
      ),
    );
  }

}

