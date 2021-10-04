import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:tinder_clone/models/user.dart';
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:tinder_clone/repositories/userRepository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tinder_clone/ui/pages/profile_picture_manager.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final String photoUrl, bio, name, gender, id;
  Timestamp  age;

  EditProfileScreen(
      {this.photoUrl, this.bio, this.name, this.age, this.gender, this.id});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var _repository = UserRepository();
  User currentuser = User();
  TextEditingController _nameController;
  final _bioController = TextEditingController();
  Timestamp age;
  var dateFormat = DateFormat('dd-MM-yyyy');


  //StorageReference _storageReference;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Name');
    _nameController.text = widget.name;
    _bioController.text = widget.bio;
    age = widget.age;
    _repository.getCurrentUser().then((users) {
      setState(() {
        currentuser = users;
      });
    });
  }

  File imageFile;

  /*Future<File> _pickImage(String action) async {
    File selectedImage;

    action == 'Gallery'
        ? selectedImage =
            await ImagePicker.pickImage(source: ImageSource.gallery)
        : await ImagePicker.pickImage(source: ImageSource.camera);

    return selectedImage;
  }*/

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        toolbarHeight: 40.0,
        elevation: 1,
        title: Text('Edit Profile', style: TextStyle(color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(Icons.done, color: Colors.blue),
            ),
            onPressed: () {
              _repository
                  .updateDetails(
                currentuser.uid,
                _nameController.text,
                _bioController.text,
                age
              )
                  .then((v) {
                Navigator.pop(context);
                // Navigator.push(context, MaterialPageRoute(
                //   builder: ((context) => InstaHomeScreen())
                // ));
              });
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: CachedNetworkImage(
                      imageUrl: widget.photoUrl,
                      imageBuilder: (context, imageProvider) =>
                          Container(
                            width: 130.0,
                            height: 130.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                      placeholder: (context, url) =>
                          Container(width: 130.0,
                              height: 130.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(130.0),
                                image: DecorationImage(
                                    image: AssetImage('assets/Black.png'),
                                    fit: BoxFit.cover),
                              )),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => Profile_picture(currentUser: widget.id, profile: false,))));
                  }),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text('Change Photo',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400)),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => Profile_picture(currentUser: widget.id, profile: false,))));
                },
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.black),
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
                    labelText: 'Name',
                    labelStyle: TextStyle(
                        color: Colors.blue, fontSize: 16.0),
                  ),
                  /*onChanged: ((value) {
                    _nameController.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.collapsed(offset: value.length),
                    );

                  }),*/
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.black),
                  controller: _bioController,
                  maxLines: 3,
                  decoration:
                  InputDecoration(hintText: 'Bio',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
                      labelText: 'Bio',
                      labelStyle: TextStyle(
                          color: Colors.blue, fontSize: 16.0)),
                  /*onChanged: ((value) {
                    _bioController.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.collapsed(offset: value.length),
                    );

                  }),*/

                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text('Date of Birth / Age', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime(1900, 1, 1),
                            maxTime: DateTime(DateTime.now().year - 19, 1, 1),
                            onConfirm: (date) {
                              setState(() {
                                age = Timestamp.fromDate(date);
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
                          dateFormat.format(age.toDate()) + ' / '+(DateTime.now().year - age.toDate().year).toString()+' years old',
                          style: TextStyle(
                              color: Colors.black, fontSize: size.width * 0.04),
                        ),
                      )
                    ],
                  )
              ),
            ],
          )
        ],
      ),
    );
  }
}