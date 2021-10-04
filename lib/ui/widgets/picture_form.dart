import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:tinder_clone/bloc/authentication/authentication_bloc.dart';
import 'package:tinder_clone/bloc/profile/bloc.dart';
import 'package:tinder_clone/repositories/userRepository.dart';
import 'package:tinder_clone/models/user.dart';
import 'package:tinder_clone/ui/constants.dart';
import 'package:tinder_clone/ui/pages/profile_picture_manager.dart';
import 'package:tinder_clone/ui/widgets/gender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:tinder_clone/ui/widgets/profileForm.dart';

class PictureForm extends StatefulWidget {
  final UserRepository _userRepository;
  String id;
  String photo;

  PictureForm({@required UserRepository userRepository, @required id, @required photo})
      : assert(userRepository != null),
        _userRepository = userRepository,
        assert(photo!=null), photo = photo, assert(id!=null), id = id;


  @override
  _PictureFormState createState() => _PictureFormState();
}

class _PictureFormState extends State<PictureForm> {
  UserRepository get _userRepository => widget._userRepository;
  ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    //_profileBloc = BlocProvider.of<ProfileBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
              padding:  EdgeInsets.only(top: size.height*0.08, bottom:  size.height*0.01),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: widget.photo.isEmpty
                    ?BoxShape.rectangle:
                    BoxShape.circle,
                    image: DecorationImage(
                      image: ProgressiveImage(
                        placeholder: AssetImage('assets/profilephoto.png'),
                        // size: 1.87KB
                        //thumbnail:NetworkImage(list[index].data()['postOwnerPhotoUrl']),
                        thumbnail: AssetImage('assets/profilephoto.png'),
                        // size: 1.29MB
                        image: widget.photo.isEmpty
                        ?AssetImage('assets/yogamates logo.png'):
                        CachedNetworkImageProvider(widget.photo),
                        //image: NetworkImage(_currentUser.photoUrl),
                        fit: BoxFit.fitWidth,
                        width: size.width * 0.4,
                        height: size.width*0.4,
                      ).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: size.width * 0.4,
                  height: size.width*0.4,
                ),
              )),
          Padding(
            padding: EdgeInsets.all( size.height*0.01),
            child: Center(
              child: GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(top: size.height*0.04),
                  child: Text('Choose Photo',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400)),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => Profile_picture(currentUser:widget.id, profile: true, userRepository: widget._userRepository, id: widget.id,))));
                },
              ),
            ),
          ),
          Container(
            width: size.width*0.5,
            padding: EdgeInsets.only(top: size.height*0.1, left: size.width*0.2, right: size.width*0.2),
            child: GestureDetector(
              child: Container(
                height: size.height*0.05,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Center(
                  child: Text('Next',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400)),
                ),
              ),
              onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => ProfileForm(userRepository: widget._userRepository))));
              },
            ),
          )
        ],
      ),
    );
  }
}

