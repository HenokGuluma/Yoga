import 'dart:io';

import 'package:tinder_clone/bloc/authentication/authentication_bloc.dart';
import 'package:tinder_clone/bloc/profile/bloc.dart';
import 'package:tinder_clone/repositories/userRepository.dart';
import 'package:tinder_clone/ui/constants.dart';
import 'package:tinder_clone/ui/widgets/gender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class ProfileForm extends StatefulWidget {
  final UserRepository _userRepository;

  ProfileForm({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String gender, interestedIn;
  DateTime age;
  File photo;
  GeoPoint location;
  ProfileBloc _profileBloc;
  var dateFormat = DateFormat('dd-MM-yyyy');

  UserRepository get _userRepository => widget._userRepository;

  bool get isFilled =>
      _nameController.text.isNotEmpty &&
          gender != null &&
          interestedIn != null &&
          photo != null &&
          age != null;

  bool isButtonEnabled(ProfileState state) {
    return isFilled && !state.isSubmitting;
  }

  _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    location = GeoPoint(position.latitude, position.longitude);
  }

  _onSubmitted() async {
    await _getLocation();
    print(_bioController.text);
    _profileBloc.add(
      Submitted(
          name: _nameController.text,
          bio: _bioController.text,
          age: age,
          location: location,
          gender: gender,
          interestedIn: interestedIn,
          photo: photo,
      verified: false),
    );
  }

  @override
  void initState() {
    _getLocation();
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    _bioController.text = '';
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocListener<ProfileBloc, ProfileState>(
      //bloc: _profileBloc,
      listener: (context, state) {
        if (state.isFailure) {
          print("Failed");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Profile Creation Unsuccessful'),
                    Icon(Icons.error)
                  ],
                ),
              ),
            );
        }
        if (state.isSubmitting) {
          print("Submitting");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Submitting'),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          print("Success!");
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: Colors.white,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: size.width,
                    child: CircleAvatar(
                      radius: size.width * 0.35,
                      backgroundColor: Colors.transparent,
                      child: photo == null
                          ? GestureDetector(
                        onTap: () async {
                          FilePickerResult getPic = await FilePicker
                              .platform
                              .pickFiles(type: FileType.image);
                          if (getPic != null) {
                            setState(() {
                              photo = File(getPic.files.first.path);
                            });
                          }
                        },
                        child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    image: AssetImage('assets/yogamates logo.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                width: size.width * 0.4,
                                height: size.width*0.4,
                              ),
                              SizedBox(
                                height: size.height*0.03,
                              ),
                              Center(
                                child: Text('Choose a photo', style: TextStyle(color: Colors.blue, fontSize: 18),),
                              ),
                            ]
                        ),
                      )
                          : GestureDetector(
                        onTap: () async {
                          FilePickerResult getPic = await FilePicker
                              .platform
                              .pickFiles(type: FileType.image);
                          if (getPic != null) {
                            setState(() {
                              photo = File(getPic.files.first.path);
                            });
                          }
                        },
                        child: Column(
                            children: [
                              CircleAvatar(
                                radius: size.width * 0.25,
                                backgroundImage: FileImage(photo),
                              ),
                              SizedBox(
                                height: size.height*0.03,
                              ),
                              Center(
                                child: Text('Choose a photo', style: TextStyle(color: Colors.blue, fontSize: 18),),
                              ),
                            ]
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),
                  textFieldWidget(_nameController, "Name", size),
                  SizedBox(
                    height: size.height*0.02,
                  ),
                  textFieldWidget(_bioController, "Bio", size),
                  GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        showTitleActions: true,
                        minTime: DateTime(1900, 1, 1),
                        maxTime: DateTime(DateTime.now().year - 19, 1, 1),
                        onConfirm: (date) {
                          setState(() {
                            age = date;
                          });
                          print(age);
                        },
                      );
                    },
                    child: age == null
                        ?Text(
                      "Enter Birthday",
                      style: TextStyle(
                          color: Colors.black, fontSize: size.width * 0.04),
                    )
                        :Text(
                      dateFormat.format(age) + ' / '+(DateTime.now().year - age.year).toString()+' years old',
                      style: TextStyle(
                          color: Colors.black, fontSize: size.width * 0.04),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.height * 0.02),
                        child: Text(
                          "You Are",
                          style: TextStyle(
                              color: Colors.black, fontSize: size.width * 0.04),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          genderWidget(
                              FontAwesomeIcons.venus, "Female", size/2, gender,
                                  () {
                                setState(() {
                                  gender = "Female";
                                });
                              }),
                          genderWidget(
                              FontAwesomeIcons.mars, "Male", size/2, gender, () {
                            setState(() {
                              gender = "Male";
                            });
                          }),
                          genderWidget(
                            FontAwesomeIcons.transgender,
                            "Transgender",
                            size/2,
                            gender,
                                () {
                              setState(
                                    () {
                                  gender = "Transgender";
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.height * 0.02),
                        child: Text(
                          "Looking For",
                          style: TextStyle(
                              color: Colors.black, fontSize: size.width * 0.04),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          genderWidget(FontAwesomeIcons.venus, "Female", size/2,
                              interestedIn, () {
                                setState(() {
                                  interestedIn = "Female";
                                });
                              }),
                          genderWidget(
                              FontAwesomeIcons.mars, "Male", size/2, interestedIn,
                                  () {
                                setState(() {
                                  interestedIn = "Male";
                                });
                              }),
                          genderWidget(
                            FontAwesomeIcons.transgender,
                            "Transgender",
                            size/2,
                            interestedIn,
                                () {
                              setState(
                                    () {
                                  interestedIn = "Transgender";
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    child: GestureDetector(
                      onTap: () {
                        if (isButtonEnabled(state)) {
                          _onSubmitted();
                        } else {}
                      },
                      child: Container(
                        width: size.width * 0.8,
                        height: size.height * 0.06,
                        decoration: BoxDecoration(
                          color: isButtonEnabled(state)
                              ? Colors.blue
                              : Colors.grey,
                          borderRadius:
                          BorderRadius.circular(size.height * 0.05),
                        ),
                        child: Center(
                            child: Text(
                              "Save",
                              style: TextStyle(
                                  fontSize: size.height * 0.025,
                                  color: isButtonEnabled(state)
                                      ?Colors.white
                                      :Colors.blue),
                            )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget textFieldWidget(controller, text, size) {
  return Padding(
    padding: EdgeInsets.all(size.height * 0.02),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: text,
        labelStyle:
        TextStyle(color: Colors.black, fontSize: size.height * 0.02),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1.0),
        ),
      ),
    ),
  );
}
